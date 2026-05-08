return {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
        options = {
            mode = "buffers",
            sort_by = "insert_at_end",
            always_show_bufferline = true,
            show_buffer_close_icons = true,
            show_close_icon = false,
            separator_style = "thin",
            indicator = { style = "underline" },
            diagnostics = "nvim_lsp",
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "  Explorer",
                    text_align = "left",
                    separator = true,
                    highlight = "Directory",
                },
            },
        },
    },
}
