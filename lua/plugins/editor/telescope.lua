return {
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local builtin = require("telescope.builtin")
            local map = function(lhs, rhs)
                vim.keymap.set("n", lhs, rhs, { silent = true })
            end

            map("<leader>ff", builtin.find_files)
            map("<leader>fg", builtin.live_grep)
            map("<leader>fr", builtin.oldfiles)
            map("<leader>fb", builtin.buffers)
            map("<leader>fh", builtin.help_tags)
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
