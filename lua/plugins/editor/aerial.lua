return {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    keys = {
        { "<leader>cO", "<cmd>AerialToggle!<cr>", desc = "Toggle Outline (Aerial)" },
        { "<leader>cN", "<cmd>AerialNavToggle<cr>", desc = "Toggle Outline Nav (Aerial)" },
        -- Avoid [[/]] (snacks.nvim owns those for LSP word references) and
        -- [s/]s (spell). Use [o/]o for outline since the symbols list is the
        -- "outline" view aerial provides.
        { "[o", "<cmd>AerialPrev<cr>", desc = "Prev Symbol (Aerial)" },
        { "]o", "<cmd>AerialNext<cr>", desc = "Next Symbol (Aerial)" },
    },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        -- LSP backend gives the most accurate symbols when an LSP is attached;
        -- treesitter fills in for filetypes without an LSP (e.g. markdown).
        backends = { "lsp", "treesitter", "markdown", "man" },
        layout = {
            min_width = 28,
            default_direction = "right",
        },
        attach_mode = "global",
        show_guides = true,
        guides = {
            mid_item = "├─",
            last_item = "└─",
            nested_top = "│ ",
            whitespace = "  ",
        },
        filter_kind = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
        },
    },
}
