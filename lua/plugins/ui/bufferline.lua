local map_key = require("utils.key_mapper").map_key

return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "famiu/bufdelete.nvim",
        },
        config = function()
            require("bufferline").setup({
                options = {
                    offsets = {
                        {
                            filetype = "neo-tree",
                            text = "File Explorer",
                            highlight = "Directory",
                            separator = true,
                        },
                    },
                    separator_style = "thin",
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                },
            })

            -- Buffer navigation
            map_key("<Tab>", ":BufferLineCycleNext<CR>")
            map_key("<S-Tab>", ":BufferLineCyclePrev<CR>")

            -- Close buffer (keep window open)
            map_key("<leader>x", ":Bdelete<CR>")
        end,
    },
}
