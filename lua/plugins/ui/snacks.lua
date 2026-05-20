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

local mgeom = require("config.modal-geom")

-- Sentinel: don't re-wrap on config reload.
if not vim.g._snacks_picker_api_patched then
    vim.g._snacks_picker_api_patched = true
    local orig_open = vim.api.nvim_open_win
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_open_win = function(buf, enter, config)
        if is_picker_preview_buf(buf) and config.col and config.width then
            config = vim.tbl_extend("force", config, { col = config.col - 1, width = config.width + 1 })
        end
        return orig_open(buf, enter, config)
    end

    local orig_set = vim.api.nvim_win_set_config
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_win_set_config = function(win, config)
        if
            vim.api.nvim_win_is_valid(win)
            and is_picker_preview_buf(vim.api.nvim_win_get_buf(win))
            and config.col
            and config.width
        then
            config = vim.tbl_extend("force", config, { col = config.col - 1, width = config.width + 1 })
        end
        return orig_set(win, config)
    end
end

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
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(win) then
            local b = vim.api.nvim_win_get_buf(win)
            if
                vim.api.nvim_buf_is_valid(b)
                and vim.bo[b].buftype ~= "terminal"
                and not SIDEBAR_FT[vim.bo[b].filetype]
            then
                vim.api.nvim_set_current_win(win)
                break
            end
        end
    end
    -- Guard in case Snacks setup failed.
    ---@diagnostic disable-next-line: undefined-field
    local S = _G.Snacks
    if S and S.dashboard then
        pcall(S.dashboard.open)
    end
end

vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup("SnacksDashboardOnLastClose", { clear = true }),
    callback = function(args)
        local closing = args.buf
        vim.schedule(function()
            open_dashboard_if_empty(closing)
        end)
    end,
})

-- damin 5-step gradient (#98ABCC → #E890B0) for the NEOVIM header.
local header_gradient = { "#98ABCC", "#ACA4C5", "#C09DBE", "#D496B7", "#E890B0" }
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
                keys = {
                    {
                        icon = " ",
                        key = "f",
                        desc = "Find",
                        action = ":lua require('fff').find_files()",
                        hidden = true,
                    },
                    {
                        icon = " ",
                        key = "g",
                        desc = "Grep",
                        action = ":lua Snacks.dashboard.pick('grep')",
                        hidden = true,
                    },
                    {
                        icon = " ",
                        key = "r",
                        desc = "Recent",
                        action = ":lua Snacks.dashboard.pick('recent')",
                        hidden = true,
                    },
                    {
                        icon = " ",
                        key = "c",
                        desc = "Config",
                        action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
                        hidden = true,
                    },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa", hidden = true },
                },
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
                table.insert(result, {
                    text = {
                        { "\u{F002}  ", hl = "Function" },
                        { "f", hl = "SnacksDashboardKey" },
                        { "      " },
                        { "\u{F00E}  ", hl = "String" },
                        { "g", hl = "SnacksDashboardKey" },
                        { "      " },
                        { "\u{F1DA}  ", hl = "Constant" },
                        { "r", hl = "SnacksDashboardKey" },
                        { "      " },
                        { "\u{F013}  ", hl = "Special" },
                        { "c", hl = "SnacksDashboardKey" },
                        { "      " },
                        { "\u{F011}  ", hl = "ErrorMsg" },
                        { "q", hl = "SnacksDashboardKey" },
                    },
                    align = "center",
                    padding = 0,
                })
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

                -- ❥ footer: uptime · plugins loaded / total. snacks's text
                -- field only accepts static segment tables (or plain strings),
                -- so stats are evaluated here per render and the segments are
                -- emitted statically.
                local stats = require("lazy").stats()
                local ms = math.floor(stats.startuptime + 0.5)
                table.insert(result, {
                    text = {
                        { "❥ ", hl = "DashHeader5" },
                        { ("%d ms"):format(ms), hl = "Comment" },
                        { "  ·  ", hl = "DashHeader3" },
                        { ("✿ %d/%d plugins"):format(stats.loaded, stats.count), hl = "Comment" },
                    },
                    align = "center",
                    padding = 1,
                })
                return result
            end,
        },
        dim = { enabled = true },
        gitbrowse = { enabled = true },
        image = { enabled = vim.env.TERM == "xterm-kitty" or vim.env.KITTY_WINDOW_ID ~= nil },
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
        scroll = { enabled = true },
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
                Snacks.bufdelete()
            end,
            desc = "Delete Buffer",
        },
        {
            "<leader>bd",
            function()
                if vim.bo.modified then
                    local choice =
                        vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
                    if choice == 1 then
                        vim.cmd.write()
                        Snacks.bufdelete()
                    elseif choice == 2 then
                        Snacks.bufdelete({ force = true })
                    end
                else
                    Snacks.bufdelete()
                end
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
    },
}
