return {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
        {
            "<leader>uc",
            function()
                require("treesitter-context").toggle()
            end,
            desc = "Toggle Treesitter Context",
        },
        {
            "[x",
            function()
                require("treesitter-context").go_to_context(vim.v.count1)
            end,
            desc = "Jump to context (upwards)",
        },
    },
    opts = {
        max_lines = 3,
        min_window_height = 16,
        multiline_threshold = 1,
        trim_scope = "outer",
        mode = "topline", -- recompute on scroll only, not on every CursorMoved
        zindex = 20,
    },
}
