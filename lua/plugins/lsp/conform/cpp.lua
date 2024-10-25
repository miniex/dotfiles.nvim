return {
	"stevearc/conform.nvim",
    config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
                cpp = { "clang-format" },
			},
		})
    end
}
