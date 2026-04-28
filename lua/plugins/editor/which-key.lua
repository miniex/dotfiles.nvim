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
            { "<leader>x", group = "diagnostics/quickfix" },
            { "<leader>r", group = "rename" },
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
