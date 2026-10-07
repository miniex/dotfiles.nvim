return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = 100,
        -- Pin to the bottom at 85% width (matches modal floats horizontally).
        win = {
            border = vim.g.flower_border,
            no_overlap = false,
            width = 0.85,
            col = 0.5,
            row = math.huge,
            height = { min = 4, max = 0.7 },
            padding = { 1, 2 },
        },
        layout = {
            width = { min = 18 },
            spacing = 2,
        },
        keys = {
            scroll_down = "<C-d>",
            scroll_up = "<C-u>",
        },
        spec = {
            { "<leader>b", group = "buffer" },
            { "<leader>c", group = "code" },
            { "<leader>d", group = "debug" },
            { "<leader>dG", group = "go" },
            { "<leader>dP", group = "python" },
            { "<leader>f", group = "find" },
            { "<leader>g", group = "git" },
            { "<leader>gh", group = "hunk" },
            { "<leader>gt", group = "toggle" },
            { "<leader>P", group = "profiler" },
            { "<leader>q", group = "session" },
            { "<leader>n", group = "neotest" },
            { "<leader>u", group = "toggle/ui" },
            { "<leader>x", group = "diagnostics/quickfix" },
            { "<leader>r", group = "rename/replace" },
            { "<leader>y", group = "yank" },
            { "<leader>z", group = "fzf" },
            { "<leader>R", group = "task" },
            { "<leader>i", group = "repl" },
            { "<leader>k", group = "rest" },
            { "<leader>s", group = "scratch" },
            { "gs", group = "surround" },
            -- Single-key desc labels (not groups; help discovery).
            { "<leader>t", desc = "Open / focus Terminal" },
            { "<leader>.", desc = "Toggle Scratch Buffer" },
            { "<leader>?", desc = "Show All Keymaps (which-key)" },
            { "<leader>w", desc = "Delete Buffer" },
            { "<leader>h", desc = "Clear search highlight" },
        },
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show()
            end,
            desc = "Show All Keymaps (which-key)",
        },
    },
}
