return {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    keys = {
        { "<leader>cO", "<cmd>AerialToggle!<cr>", desc = "Toggle Outline (Aerial)" },
        { "<leader>cN", "<cmd>AerialNavToggle<cr>", desc = "Toggle Outline Nav (Aerial)" },
        -- [o/]o: [[/]] owned by snacks (LSP refs), [s/]s by spell.
        { "[o", "<cmd>AerialPrev<cr>", desc = "Prev Symbol (Aerial)" },
        { "]o", "<cmd>AerialNext<cr>", desc = "Next Symbol (Aerial)" },
    },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        -- LSP first (accurate); treesitter fallback (markdown etc.).
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
