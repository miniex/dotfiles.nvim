return {
	"stevearc/conform.nvim",
    config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
                css = { { "prettierd", "prettier" } },
                sass = { { "prettierd", "prettier" } },
                scss = { { "prettierd", "prettier" } },
			},
		})
    end
}
