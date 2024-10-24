return {
	"rose-pine/neovim",
	name = "rose-pine",
	lazy = false,
	config = function()
		require("rose-pine").setup({
			variant = "moon",
			dark_variant = "moon",
		})

		vim.cmd([[colorscheme rose-pine]])
	end,
}
