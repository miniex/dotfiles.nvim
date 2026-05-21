return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
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
            { "<leader>gv", group = "diffview" },
            { "<leader>gx", group = "conflict" },
            { "<leader>P", group = "profiler" },
            { "<leader>q", group = "session" },
            { "<leader>m", group = "harpoon" },
            { "<leader>M", group = "multicursor" },
            { "<leader>n", group = "neotest" },
            { "<leader>u", group = "toggle/ui" },
            { "<leader>x", group = "diagnostics/quickfix" },
            { "<leader>r", group = "rename/replace" },
            { "<leader>z", group = "fzf" },
            { "gs", group = "surround" },
            { "gn", group = "ts-select" },
            -- Single-key desc labels (not groups; help discovery).
            { "<leader>e", desc = "Neo-tree toggle" },
            { "<leader>o", desc = "Neo-tree reveal" },
            { "<leader>t", desc = "Terminal toggle" },
            { "<leader>.", desc = "Scratch buffer" },
            { "<leader>?", desc = "Show all keymaps" },
            { "<leader>w", desc = "Delete buffer" },
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
