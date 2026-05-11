return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
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
            { "<leader>p", group = "profiler", mode = "n" },
            { "<leader>q", group = "session" },
            { "<leader>m", group = "harpoon" },
            { "<leader>n", group = "neotest" },
            { "<leader>u", group = "toggle/ui" },
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
