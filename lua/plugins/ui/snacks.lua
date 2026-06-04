local SIDEBAR_FT = {
    ["neo-tree"] = true,
    ["neo-tree-popup"] = true,
}

-- Nudge picker preview's left border onto list's right border (col -1 /
-- width +1). List's zindex (52) wins the shared column, leaving one ✿│✿
-- divider. Preview is identified by snacks's scratch_ft (preview.lua:84).
local function is_picker_preview_buf(buf)
    return buf and buf ~= 0 and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "snacks_picker_preview"
end

local function shift_preview(config)
    return vim.tbl_extend("force", config, { col = config.col - 1, width = config.width + 1 })
end

local mgeom = require("config.modal-geom")

require("config.modal-floats").add_decorator("snacks_picker_preview", {
    open = function(buf, config)
        if is_picker_preview_buf(buf) and config.col and config.width then
            return shift_preview(config)
        end
    end,
    set_config = function(win, config)
        if
            vim.api.nvim_win_is_valid(win)
            and is_picker_preview_buf(vim.api.nvim_win_get_buf(win))
            and config.col
            and config.width
        then
            return shift_preview(config)
        end
    end,
})

-- $EDITOR → parent nvim. Pass at toggle(), not opts.terminal (snacks id mismatch).
local TERM_WRAPPER = vim.fn.stdpath("config") .. "/scripts/term-bin/nvim"
local TERM_ENV = {
    EDITOR = TERM_WRAPPER,
    VISUAL = TERM_WRAPPER,
    GIT_EDITOR = TERM_WRAPPER,
}

-- Disable overlays on dashboard: chafa ANSI conflicts with dim/indent/scroll.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "snacks_dashboard",
    group = vim.api.nvim_create_augroup("SnacksDashboardOverlay", { clear = true }),
    callback = function(args)
        vim.b[args.buf].snacks_dim = false
        vim.b[args.buf].snacks_indent = false
        vim.b[args.buf].snacks_scroll = false
    end,
})

local function pick_main_win()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
            local b = vim.api.nvim_win_get_buf(win)
            if
                vim.api.nvim_buf_is_valid(b)
                and vim.bo[b].buftype ~= "terminal"
                and not SIDEBAR_FT[vim.bo[b].filetype]
            then
                return win
            end
        end
    end
end

local function open_dashboard()
    local main_win = pick_main_win()
    if not main_win then
        return
    end
    vim.api.nvim_set_current_win(main_win)
    ---@diagnostic disable-next-line: undefined-field
    local S = _G.Snacks
    if S and S.dashboard then
        -- `win` replaces the main buffer in place instead of floating over [No Name].
        pcall(S.dashboard.open, { win = main_win })
    end
end

-- On last file buffer close → dashboard in main window (avoid [No Name]).
local function open_dashboard_if_empty(closing)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
            buf ~= closing
            and vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].buflisted
            and vim.bo[buf].buftype == ""
            and vim.api.nvim_buf_get_name(buf) ~= ""
        then
            return
        end
    end
    open_dashboard()
end

-- Skip terminals and the dashboard itself — those bounce back or jump into a terminal.
local function is_real_file_buf(buf)
    return buf > 0
        and vim.api.nvim_buf_is_valid(buf)
        and vim.bo[buf].buftype == ""
        and vim.api.nvim_buf_get_name(buf) ~= ""
end

local function pick_alt_file_buf()
    local alt = vim.fn.bufnr("#")
    if is_real_file_buf(alt) then
        return alt
    end
    local infos = vim.fn.getbufinfo({ buflisted = 1 })
    table.sort(infos, function(a, b)
        return a.lastused > b.lastused
    end)
    for _, info in ipairs(infos) do
        if is_real_file_buf(info.bufnr) then
            return info.bufnr
        end
    end
end

local function toggle_dashboard()
    if vim.bo.filetype == "snacks_dashboard" then
        local target = pick_alt_file_buf()
        if target then
            vim.cmd.buffer(target)
        end
    else
        open_dashboard()
    end
end

-- Unlisted dashboard buf → `:mksession` writes `enew`; swap to alternate first.
vim.api.nvim_create_autocmd("User", {
    pattern = "PersistenceSavePre",
    group = vim.api.nvim_create_augroup("SnacksDashboardSavePre", { clear = true }),
    callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local b = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_is_valid(b) and vim.bo[b].filetype == "snacks_dashboard" then
                vim.api.nvim_win_call(win, function()
                    local target = pick_alt_file_buf()
                    if target then
                        vim.cmd.buffer(target)
                    end
                end)
            end
        end
    end,
})

vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup("SnacksDashboardOnLastClose", { clear = true }),
    callback = function(args)
        -- Skip terminals / help / scratches — only file buffer closes can leave the editor "empty".
        if not vim.api.nvim_buf_is_valid(args.buf) then
            return
        end
        if vim.bo[args.buf].buftype ~= "" or not vim.bo[args.buf].buflisted then
            return
        end
        local closing = args.buf
        vim.schedule(function()
            open_dashboard_if_empty(closing)
        end)
    end,
})

-- Source-of-truth for dashboard shortcuts: feeds preset.keys + the icon strip.
local DASH_KEYS = {
    {
        key = "f",
        icon = "\u{F002}",
        icon_hl = "Function",
        desc = "Find",
        action = ":lua require('fff').find_files()",
    },
    {
        key = "g",
        icon = "\u{F00E}",
        icon_hl = "String",
        desc = "Grep",
        action = ":lua Snacks.dashboard.pick('grep')",
    },
    {
        key = "r",
        icon = "\u{F1DA}",
        icon_hl = "Constant",
        desc = "Recent",
        action = ":lua Snacks.dashboard.pick('recent')",
    },
    {
        key = "c",
        icon = "\u{F013}",
        icon_hl = "Special",
        desc = "Config",
        action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
    },
    { key = "q", icon = "\u{F011}", icon_hl = "ErrorMsg", desc = "Quit", action = ":qa" },
}

-- damin 5-step gradient (blue → pink) for the NEOVIM header.
local pal = require("config.palette")
local header_gradient = { pal.blue, "#ACA4C5", pal.mid, "#D496B7", pal.pink }
local function set_header_hl()
    for i, color in ipairs(header_gradient) do
        vim.api.nvim_set_hl(0, "DashHeader" .. i, { fg = color, bold = true })
    end
end
set_header_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("DashHeaderGradient", { clear = true }),
    callback = set_header_hl,
})

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        bufdelete = { enabled = true },
        dashboard = {
            enabled = true,
            preset = {
                keys = vim.tbl_map(function(k)
                    return {
                        icon = k.icon .. " ",
                        key = k.key,
                        desc = k.desc,
                        action = k.action,
                        hidden = true,
                    }
                end, DASH_KEYS),
            },
            -- Responsive: drop header → recent on small heights. Image/menu/startup always.
            sections = function(self)
                local h = self:size().height
                local result = {}
                local sticker = vim.fn.stdpath("config") .. "/assets/dashboard_sticker.ansi"
                if vim.fn.filereadable(sticker) == 1 then
                    table.insert(result, {
                        section = "terminal",
                        cmd = "cat " .. vim.fn.shellescape(sticker),
                        height = 24,
                        width = 60,
                        padding = 1,
                        align = "center",
                    })
                end

                if h >= 40 then
                    table.insert(result, {
                        text = { [[ _   _  _____   ___  __     __ ___  __  __ ]], hl = "DashHeader1" },
                        align = "center",
                        padding = 0,
                    })
                    table.insert(result, {
                        text = { [[| \ | || ____| / _ \ \ \   / /|_ _||  \/  |]], hl = "DashHeader2" },
                        align = "center",
                        padding = 0,
                    })
                    table.insert(result, {
                        text = { [[|  \| ||  _|  | | | | \ \ / /  | | | |\/| |]], hl = "DashHeader3" },
                        align = "center",
                        padding = 0,
                    })
                    table.insert(result, {
                        text = { [[| |\  || |___ | |_| |  \ V /   | | | |  | |]], hl = "DashHeader4" },
                        align = "center",
                        padding = 0,
                    })
                    table.insert(result, {
                        text = { [[|_| \_||_____| \___/    \_/   |___||_|  |_|]], hl = "DashHeader5" },
                        align = "center",
                        padding = 1,
                    })
                end

                -- keys section keeps bindings live; render as compact icon strip.
                table.insert(result, { section = "keys", padding = 0 })
                local strip = {}
                for i, k in ipairs(DASH_KEYS) do
                    if i > 1 then
                        table.insert(strip, { "      " })
                    end
                    table.insert(strip, { k.icon .. "  ", hl = k.icon_hl })
                    table.insert(strip, { k.key, hl = "SnacksDashboardKey" })
                end
                table.insert(result, { text = strip, align = "center", padding = 0 })
                table.insert(result, {
                    text = {
                        { "press ", hl = "Comment" },
                        { "<leader>?", hl = "SnacksDashboardKey" },
                        { " for keymaps  (", hl = "Comment" },
                        { "<C-d>", hl = "SnacksDashboardKey" },
                        { "/", hl = "Comment" },
                        { "<C-u>", hl = "SnacksDashboardKey" },
                        { " to flip pages)", hl = "Comment" },
                    },
                    align = "center",
                    padding = 1,
                })

                if h >= 34 then
                    table.insert(
                        result,
                        { icon = " ", title = "Recent Files", section = "recent_files", limit = 5, padding = 1 }
                    )
                end

                -- ❥ footer: uptime · plugins · (session hint if one exists for cwd).
                local stats = require("lazy").stats()
                local ms = math.floor(stats.startuptime + 0.5)
                local segments = {
                    { "❥ ", hl = "DashHeader5" },
                    { ("%d ms"):format(ms), hl = "Comment" },
                    { "  ·  ", hl = "DashHeader3" },
                    { ("✿ %d/%d plugins"):format(stats.loaded, stats.count), hl = "Comment" },
                }
                local ok_p, persistence = pcall(require, "persistence")
                if ok_p and vim.fn.filereadable(persistence.current()) == 1 then
                    table.insert(segments, { "  ·  ", hl = "DashHeader3" })
                    table.insert(segments, { "✦ ", hl = "DashHeader5" })
                    table.insert(segments, { "<leader>qs to restore", hl = "Comment" })
                end
                table.insert(result, {
                    text = segments,
                    align = "center",
                    padding = 1,
                })
                return result
            end,
        },
        dim = { enabled = true },
        gitbrowse = { enabled = true },
        -- kitty graphics protocol: kitty, WezTerm, and Ghostty all support it.
        image = {
            enabled = vim.env.TERM == "xterm-kitty"
                or vim.env.KITTY_WINDOW_ID ~= nil
                or vim.env.WEZTERM_EXECUTABLE ~= nil
                or vim.env.WEZTERM_PANE ~= nil
                or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
                or vim.env.GHOSTTY_BIN_DIR ~= nil
                or vim.env.TERM == "xterm-ghostty",
        },
        indent = {
            enabled = true,
            indent = { char = "┊" },
            scope = { char = "╎", underline = false },
            chunk = { enabled = false },
        },
        input = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000,
        },
        picker = {
            enabled = true,
            ui_select = true,
            -- Two flower-bordered boxes adjacent; col-overlap (see
            -- `is_picker_preview_buf` patch at top) renders one ✿│✿ divider.
            layouts = {
                default = {
                    layout = {
                        box = "horizontal",
                        width = mgeom.width,
                        height = mgeom.height,
                        row = mgeom.row,
                        col = mgeom.col,
                        border = "none",
                        {
                            box = "vertical",
                            border = vim.g.flower_border,
                            title = " ✿ {title} {live} {flags} ✿ ",
                            title_pos = "center",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", border = "none" },
                        },
                        {
                            win = "preview",
                            title = " ✿ {preview} ✿ ",
                            title_pos = "center",
                            border = vim.g.flower_border,
                            width = 0.5,
                        },
                    },
                },
            },
            win = {
                input = {
                    keys = { ["<Esc>"] = { "close", mode = { "n", "i" } } },
                },
            },
        },
        profiler = {
            -- `PROF=1 nvim` for startup; keymaps below for runtime toggle.
        },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scratch = { enabled = true },
        -- outQuad + 150ms (vs default linear/250ms) so key-repeat doesn't queue behind the animation.
        scroll = {
            enabled = true,
            animate = {
                duration = { step = 10, total = 150 },
                easing = "outQuad",
            },
            animate_repeat = {
                delay = 80,
                duration = { step = 5, total = 40 },
                easing = "linear",
            },
        },
        statuscolumn = { enabled = true },
        terminal = {
            enabled = true,
            win = {
                position = "float",
                width = mgeom.inner_width,
                height = mgeom.inner_height,
                row = mgeom.row,
                col = mgeom.col,
                border = vim.g.flower_border,
                title = " ✿ terminal ✿ ",
                title_pos = "center",
                wo = { winbar = "", winblend = 0 },
                keys = {
                    term_close = { "<C-x>", "hide", mode = { "n", "t" }, desc = "Hide Terminal" },
                },
            },
        },
        lazygit = {
            -- Snacks.lazygit runs through Snacks.terminal and would inherit its
            -- " ✿ terminal ✿ " title; set lazygit's own win to override it.
            win = {
                title = " ✿ lazygit ✿ ",
                title_pos = "center",
                border = vim.g.flower_border,
                width = mgeom.inner_width,
                height = mgeom.inner_height,
                row = mgeom.row,
                col = mgeom.col,
            },
        },
        words = { enabled = true },
        zen = { enabled = true },
        -- Override snacks's built-in window styles. Each style has its own default
        -- border; pinning them all to flower keeps the UI consistent.
        styles = {
            notification = { border = vim.g.flower_border },
            notification_history = { border = vim.g.flower_border },
            input = { border = vim.g.flower_border, relative = "cursor" },
            scratch = { border = vim.g.flower_border },
            zen = { border = vim.g.flower_border },
            float = { border = vim.g.flower_border },
        },
    },
    config = function(_, opts)
        require("snacks").setup(opts)
        -- Option toggles with which-key labels + state. Custom toggles stay with their plugins.
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>ur")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option("conceallevel", { off = 0, on = 2 }):map("<leader>uo")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.inlay_hints():map("<leader>ci"):map("<leader>uh")
    end,
    keys = {
        {
            "<leader>fg",
            function()
                Snacks.picker.grep()
            end,
            desc = "Live Grep",
        },
        {
            "<leader>fr",
            function()
                Snacks.picker.recent()
            end,
            desc = "Recent Files",
        },
        {
            "<leader>fb",
            function()
                Snacks.picker.buffers()
            end,
            desc = "Buffers",
        },
        {
            "<leader>fh",
            function()
                Snacks.picker.help()
            end,
            desc = "Help Tags",
        },
        {
            "<leader>w",
            function()
                -- Dashboard → file buf if any, else exit.
                if vim.bo.filetype == "snacks_dashboard" then
                    local target = pick_alt_file_buf()
                    if target then
                        vim.cmd.buffer(target)
                    else
                        vim.cmd("qall")
                    end
                    return
                end
                Snacks.bufdelete()
            end,
            desc = "Delete Buffer",
        },
        {
            "<leader>;",
            function()
                toggle_dashboard()
            end,
            desc = "Toggle Dashboard",
        },
        {
            "<leader>bd",
            function()
                Snacks.bufdelete()
            end,
            desc = "Delete Buffer (confirm if modified)",
        },
        {
            "<leader>bD",
            function()
                Snacks.bufdelete({ force = true })
            end,
            desc = "Delete Buffer (force)",
        },
        {
            "<leader>t",
            function()
                Snacks.terminal.toggle(nil, { env = TERM_ENV })
            end,
            mode = { "n", "t" },
            desc = "Toggle Terminal",
        },
        {
            "<leader>un",
            function()
                Snacks.notifier.hide()
            end,
            desc = "Dismiss All Notifications",
        },
        {
            "<leader>cn",
            function()
                Snacks.notifier.show_history()
            end,
            desc = "Notification History",
        },
        -- Profiler under <leader>P* to free <leader>p (paste in visual).
        {
            "<leader>Pp",
            function()
                Snacks.profiler.toggle()
            end,
            desc = "Profiler Toggle",
        },
        {
            "<leader>Ps",
            function()
                Snacks.profiler.scratch()
            end,
            desc = "Profiler Scratch Buffer",
        },
        {
            "<leader>Pf",
            function()
                Snacks.profiler.pick()
            end,
            desc = "Profiler Pick",
        },
        {
            "<leader>Ph",
            function()
                Snacks.profiler.highlights()
            end,
            desc = "Profiler Highlights",
        },
        {
            "]]",
            function()
                Snacks.words.jump(vim.v.count1)
            end,
            mode = { "n", "t" },
            desc = "Next Reference",
        },
        {
            "[[",
            function()
                Snacks.words.jump(-vim.v.count1)
            end,
            mode = { "n", "t" },
            desc = "Prev Reference",
        },
        {
            "]i",
            function()
                Snacks.scope.jump({ bottom = true })
            end,
            mode = { "n", "x", "o" },
            desc = "Jump to Scope Bottom",
        },
        {
            "[i",
            function()
                Snacks.scope.jump({ bottom = false })
            end,
            mode = { "n", "x", "o" },
            desc = "Jump to Scope Top",
        },
        {
            "<leader>.",
            function()
                Snacks.scratch()
            end,
            desc = "Toggle Scratch Buffer",
        },
        {
            "<leader>bS",
            function()
                Snacks.scratch.select()
            end,
            desc = "Select Scratch Buffer",
        },
        {
            "<leader>uz",
            function()
                Snacks.zen()
            end,
            desc = "Toggle Zen Mode",
        },
        {
            "<leader>uZ",
            function()
                Snacks.zen.zoom()
            end,
            desc = "Toggle Zen Zoom",
        },
        {
            "<leader>fR",
            function()
                Snacks.rename.rename_file()
            end,
            desc = "Rename File (LSP-aware)",
        },
        {
            "<leader>gB",
            function()
                Snacks.gitbrowse()
            end,
            mode = { "n", "v" },
            desc = "Git Browse (open in browser)",
        },
        {
            "<leader>gg",
            function()
                Snacks.lazygit()
            end,
            desc = "LazyGit",
        },
        {
            "<leader>gf",
            function()
                Snacks.lazygit.log_file()
            end,
            desc = "LazyGit File History",
        },
        {
            "<leader>gL",
            function()
                Snacks.lazygit.log()
            end,
            desc = "LazyGit Log",
        },
    },
}
