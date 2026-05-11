return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        spec = {
            { "<leader>c", group = "code" },
            { "<leader>f", group = "find" },
            { "<leader>g", group = "git" },
            { "<leader>gh", group = "hunk" },
            { "<leader>gt", group = "toggle" },
            { "<leader>gv", group = "diffview" },
            { "<leader>p", group = "profiler", mode = "n" },
            { "<leader>q", group = "session" },
            { "<leader>n", group = "neotest" },
            { "<leader>x", group = "diagnostics/quickfix" },
            { "<leader>r", group = "rename" },
            { "<leader>z", group = "fzf" },
            { "gs", group = "surround" },
        },
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}
