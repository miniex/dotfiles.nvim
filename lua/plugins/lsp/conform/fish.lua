return {
	"stevearc/conform.nvim",
    config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
                fish = { "fish_indent" },
			},
		})
    end
}
