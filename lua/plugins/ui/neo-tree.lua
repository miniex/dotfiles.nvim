-- damin polish: pink float border + pink "currently editing" file.
-- Applied from `config`, not here — module top runs at startup even if neo-tree never opens.
local function apply_hl()
    local pink = require("config.palette").pink
    vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { fg = pink, bg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { fg = pink, bold = true })
    vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", { fg = pink, italic = true, bold = true })
end

-- neo-tree's filesize lib divides by 1024 but labels it with SI symbols
-- (KB/MB/…). Remap to IEC units so the value and label agree (KiB/MiB/…).
local function patch_iec_units()
    local utils = require("neo-tree.utils")
    if utils._damin_iec then
        return
    end
    utils._damin_iec = true
    local filesize = require("neo-tree.utils.filesize.filesize")
    local IEC = { KB = "KiB", MB = "MiB", GB = "GiB", TB = "TiB", PB = "PiB", EB = "EiB", ZB = "ZiB", YB = "YiB" }
    -- file_size (files) and patch_recursive_dir_size (dirs) both call this.
    utils.human_size = function(size)
        return filesize(size, { output = "string", suffixes = IEC })
    end
end

-- Show recursive size on directory rows (neo-tree's default is "-"). The scan
-- runs on a libuv worker thread (vim.uv.new_work) — off the main loop, so no lag.
-- MAX_ENTRIES backstops giant roots (">…").
local function patch_recursive_dir_size()
    local common = require("neo-tree.sources.common.components")
    -- Reload-safe: don't wrap an already-wrapped file_size (would re-subscribe
    -- FS_EVENT and orphan the prior cache).
    if common._damin_size_patched then
        return
    end
    common._damin_size_patched = true

    local utils = require("neo-tree.utils")
    local events = require("neo-tree.events")
    local uv = vim.uv or vim.loop

    local MAX_ENTRIES = 1000000 -- per-dir backstop; ">…" beyond it
    local cache = {} -- path -> bytes | "capped"
    local inflight = {} -- path -> true while computing

    -- Self-contained (string.dump'able, no upvalues): runs on a libuv worker
    -- thread. Returns total bytes, or -1 if MAX_ENTRIES is exceeded.
    local function scan_blocking(root, max_entries)
        local luv = require("luv")
        local total, entries = 0, 0
        local stack = { root }
        while #stack > 0 do
            local dir = table.remove(stack)
            local fd = luv.fs_scandir(dir)
            if fd then
                while true do
                    local name, t = luv.fs_scandir_next(fd)
                    if not name then
                        break
                    end
                    entries = entries + 1
                    if entries > max_entries then
                        return -1
                    end
                    local child = dir .. "/" .. name
                    if t == "directory" then
                        stack[#stack + 1] = child
                    elseif t == "file" then
                        local st = luv.fs_stat(child)
                        if st then
                            total = total + st.size
                        end
                    end
                end
            end
        end
        return total
    end

    -- Recursive size of `root` on a libuv worker thread. Cap concurrent scans so a
    -- burst of dirs can't hog the shared ~4-thread pool; the rest queue. cb(nil) if capped.
    local MAX_SCANS = 3
    local scan_queue, active_scans = {}, 0
    local function dispatch_scans()
        while active_scans < MAX_SCANS and #scan_queue > 0 do
            local job = table.remove(scan_queue, 1)
            active_scans = active_scans + 1
            uv.new_work(scan_blocking, function(result)
                active_scans = active_scans - 1
                job.cb(result < 0 and nil or result)
                dispatch_scans()
            end):queue(job.root, MAX_ENTRIES)
        end
    end
    local function compute_async(root, cb)
        scan_queue[#scan_queue + 1] = { root = root, cb = cb }
        dispatch_scans()
    end

    -- Braille spinner while sizes compute; render-only redraw (no FS re-scan, unlike
    -- refresh) keeps the cursor put. Runs only while computes are in flight.
    local SPINNER = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    local spin = 1
    local spin_timer = uv.new_timer()
    local spinning = false
    local function ensure_spinner()
        if spinning then
            return
        end
        spinning = true
        spin_timer:start(
            90,
            90,
            vim.schedule_wrap(function()
                spin = spin % #SPINNER + 1
                local done = next(inflight) == nil
                pcall(function()
                    require("neo-tree.sources.manager").redraw("filesystem")
                end)
                if done then
                    spin_timer:stop()
                    spinning = false
                end
            end)
        )
    end
    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            if spin_timer and not spin_timer:is_closing() then
                spin_timer:stop()
                spin_timer:close()
            end
        end,
    })

    local original = common.file_size
    common.file_size = function(config, node, state)
        if node:get_depth() ~= 1 and node.type == "directory" then
            local path = node:get_id()
            local entry = cache[path]
            local text
            if entry == "capped" then
                text = ">…"
            elseif entry ~= nil then
                local ok, human = pcall(utils.human_size, entry)
                text = (ok and human) or "-"
            else
                text = SPINNER[spin]
                if not inflight[path] then
                    inflight[path] = true
                    compute_async(path, function(bytes)
                        inflight[path] = nil
                        cache[path] = bytes == nil and "capped" or bytes
                    end)
                    ensure_spinner()
                end
            end
            local width = config.width or 12
            return {
                text = vim.fn.printf("%" .. width .. "s  ", text),
                highlight = config.highlight or "NeoTreeFileStats",
            }
        end
        return original(config, node, state)
    end

    -- Invalidate the changed dir + ancestors (totals include it) + descendants (the
    -- event path is the watched dir, so a change may be deeper) — not the whole cache.
    events.subscribe({
        event = events.FS_EVENT,
        handler = function(args)
            local changed = args and args.afile
            if not changed then
                cache = {}
                return
            end
            for path in pairs(cache) do
                if
                    path == changed
                    or vim.startswith(changed, path .. "/") -- ancestors of changed
                    or vim.startswith(path, changed .. "/") -- descendants of changed
                then
                    cache[path] = nil
                end
            end
        end,
    })
end

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
        { "<leader>e", ":Neotree toggle<cr>", silent = true, desc = "Neo-tree toggle" },
        { "<leader>o", ":Neotree reveal<cr>", silent = true, desc = "Neo-tree reveal" },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function(_, opts)
        require("neo-tree").setup(opts)
        apply_hl()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("NeoTreeDaminHL", { clear = true }),
            callback = apply_hl,
        })
        patch_iec_units()
        patch_recursive_dir_size()
    end,
    opts = {
        close_if_last_window = true,
        -- Flower border for secondary popups too (rename/preview); the main
        -- float uses window.popup.border.style below.
        popup_border_style = vim.g.flower_border,
        enable_git_status = true,
        enable_diagnostics = true,

        default_component_configs = {
            container = { enable_character_fade = true },
            indent = {
                indent_size = 1,
                padding = 1,
                with_markers = true,
                indent_marker = "┊",
                last_indent_marker = "╰",
                highlight = "NeoTreeIndentMarker",
                with_expanders = true,
                expander_collapsed = "❯",
                expander_expanded = "❮",
            },
            icon = {
                folder_closed = "",
                folder_open = "",
                folder_empty = "󰜌",
                default = "󰈚",
                highlight = "NeoTreeFileIcon",
            },
            modified = {
                symbol = "✿",
                highlight = "NeoTreeModified",
            },
            name = {
                trailing_slash = true,
                use_git_status_colors = true,
            },
            -- Dingbats only — mirrors fish-theme-damin, no nerd-font dependency.
            git_status = {
                symbols = {
                    added = "✦",
                    modified = "✿",
                    deleted = "✗",
                    renamed = "❀",
                    untracked = "❁",
                    ignored = "·",
                    unstaged = "✧",
                    staged = "✓",
                    conflict = "✺",
                },
            },
        },

        window = {
            position = "float",
            popup = {
                border = {
                    style = vim.g.flower_border,
                    text = { top = vim.g.flower_title("files"), top_align = "center" },
                },
                -- Function callbacks track the shared modal-geom rectangle
                -- on every open (resolve_config_option re-evaluates each time).
                size = function()
                    local mg = require("config.modal-geom")
                    return { width = mg.inner_width(), height = mg.inner_height() }
                end,
                position = function()
                    -- +1 cancels nui's half-border position adjustment.
                    local mg = require("config.modal-geom")
                    return { row = mg.row() + 1, col = mg.col() + 1 }
                end,
            },
            mapping_options = { noremap = true, nowait = true },
            mappings = {
                ["<space>"] = "none",
                ["<cr>"] = "open_in_main",
                ["l"] = "open_in_main",
                ["h"] = "close_node",
            },
        },

        -- Float mode workaround: neo-tree's native open hits invalid winid.
        commands = {
            open_in_main = function(state)
                local utils = require("neo-tree.utils")
                local node = state.tree:get_node()
                if utils.is_expandable(node) then
                    local fs = require("neo-tree.sources.filesystem")
                    return require("neo-tree.sources.common.commands").toggle_node(
                        state,
                        utils.wrap(fs.toggle_directory, state)
                    )
                end
                local main
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.api.nvim_win_get_config(win).relative == "" and vim.bo[buf].buftype ~= "terminal" then
                        main = win
                        break
                    end
                end
                require("neo-tree.command").execute({ action = "close" })
                local path = vim.fn.fnameescape(node:get_id())
                if main and vim.api.nvim_win_is_valid(main) then
                    vim.api.nvim_set_current_win(main)
                    vim.cmd("edit " .. path)
                else
                    vim.cmd("tabnew " .. path)
                end
            end,
        },

        filesystem = {
            filtered_items = {
                visible = false,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_by_name = {
                    ".git",
                    ".DS_Store",
                    "thumbs.db",
                    "node_modules",
                    "__pycache__",
                    ".idea",
                    ".vscode",
                    ".ruff_cache",
                },
            },
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
        },
    },
}
