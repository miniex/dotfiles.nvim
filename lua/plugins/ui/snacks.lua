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
                header = table.concat({
                    [[        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗       ]],
                    [[        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║       ]],
                    [[        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║       ]],
                    [[        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║       ]],
                    [[        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║       ]],
                    [[        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝       ]],
                }, "\n"),
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                    { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
                    { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
                    {
                        icon = " ",
                        key = "c",
                        desc = "Config",
                        action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
                    },
                    { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
            },
            sections = {
                { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
                { icon = " ", title = "Recent Files", section = "recent_files", limit = 5, padding = 1 },
                { section = "startup" },
            },
        },
        dim = { enabled = true },
        image = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000,
        },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        terminal = {
            enabled = true,
            win = {
                position = "bottom",
                height = 0.3,
                wo = { winbar = "" },
                keys = {
                    term_close = { "<C-x>", "hide", mode = { "n", "t" }, desc = "Hide Terminal" },
                },
            },
        },
        words = { enabled = true },
    },
    keys = {
        {
            "<leader>bd",
            function()
                Snacks.bufdelete()
            end,
            desc = "Delete Buffer",
        },
        {
            "<leader>t",
            function()
                Snacks.terminal.toggle()
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
