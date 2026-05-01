return {
    "OXY2DEV/markview.nvim",
    ft = { "markdown", "mdx", "typst" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
        {
            "<leader>um",
            "<cmd>Markview Toggle<cr>",
            desc = "Toggle Markview",
        },
        {
            "<leader>uM",
            "<cmd>Markview splitToggle<cr>",
            desc = "Toggle Markview Split Preview",
        },
    },
    opts = {
        preview = {
            modes = { "n", "no", "c" },
            hybrid_modes = { "n" },
            filetypes = { "markdown", "mdx", "typst" },
            ignore_buftypes = { "nofile", "terminal", "prompt", "help" },
        },
        markdown = {
            headings = {
                shift_width = 0,
            },
        },
        typst = {
            enable = true,
        },
    },
}
