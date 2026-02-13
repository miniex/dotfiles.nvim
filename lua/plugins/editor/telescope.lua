local map_key = require("utils.key_mapper").map_key

return {
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function()
            local builtin = require("telescope.builtin")

            map_key("<leader>ff", builtin.find_files)
            map_key("<leader>fg", builtin.live_grep)
            map_key("<leader>fr", builtin.oldfiles)
            map_key("<leader>fb", builtin.buffers)
            map_key("<leader>fh", builtin.help_tags)
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })
            require("telescope").load_extension("ui-select")
        end,
    },
}
