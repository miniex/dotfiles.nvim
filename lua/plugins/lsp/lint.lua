return {
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "shellcheck",
                "eslint_d",
                "markdownlint",
            },
        },
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                sh = { "shellcheck" },
                bash = { "shellcheck" },
                zsh = { "zsh" },
                fish = { "fish" },
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                -- python lint handled by ruff LSP (see lang/python.lua)
                markdown = { "markdownlint" },
            }

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
