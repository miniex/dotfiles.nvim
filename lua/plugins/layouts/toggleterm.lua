local map_key = require("utils.key_mapper").map_key

return {
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup({
                direction = "float",
                float_opts = {
                    border = "double",
                },
            })

			map_key("<leader>t", ":ToggleTerm<CR>")
		end,
	},
}
