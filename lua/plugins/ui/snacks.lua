local SIDEBAR_FT = {
    ["neo-tree"] = true,
    ["neo-tree-popup"] = true,
}

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
        local b = vim.api.nvim_win_get_buf(win)
        if vim.bo[b].buftype ~= "terminal" and not SIDEBAR_FT[vim.bo[b].filetype] then
            vim.api.nvim_set_current_win(win)
            break
        end
    end
    Snacks.dashboard.open()
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
                local result = {
                    {
                        section = "terminal",
                        cmd = "cat " .. vim.fn.stdpath("config") .. "/assets/dashboard_sticker.ansi",
                        height = 24,
                        width = 60,
                        padding = 1,
                        align = "center",
                    },
                }

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
                    padding = 1,
                })

                if h >= 34 then
                    table.insert(
                        result,
                        { icon = " ", title = "Recent Files", section = "recent_files", limit = 5, padding = 1 }
                    )
                end

                table.insert(result, { section = "startup" })
                return result
            end,
        },
        dim = { enabled = true },
        image = { enabled = vim.env.TERM == "xterm-kitty" or vim.env.KITTY_WINDOW_ID ~= nil },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000,
        },
        picker = {
            enabled = true,
            ui_select = true,
            win = {
                input = {
                    border = "rounded",
                    keys = {
                        ["<Esc>"] = { "close", mode = { "n", "i" } },
                    },
                },
                list = { border = "rounded" },
                preview = { border = "rounded" },
            },
        },
        profiler = {
            -- `PROF=1 nvim` for startup; keymaps below for runtime toggle.
        },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        terminal = {
            enabled = true,
            win = {
                position = "float",
                width = 0.85,
                height = 0.85,
                border = "rounded",
                wo = { winbar = "", winblend = 0 },
                keys = {
                    term_close = { "<C-x>", "hide", mode = { "n", "t" }, desc = "Hide Terminal" },
                },
            },
        },
        words = { enabled = true },
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
        {
            "<leader>pp",
            function()
                Snacks.profiler.toggle()
            end,
            desc = "Profiler Toggle",
        },
        {
            "<leader>ps",
            function()
                Snacks.profiler.scratch()
            end,
            desc = "Profiler Scratch Buffer",
        },
        {
            "<leader>pf",
            function()
                Snacks.profiler.pick()
            end,
            desc = "Profiler Pick",
        },
        {
            "<leader>ph",
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
    },
}
