return {
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            -- Sorted by language category.
            ensure_installed = {
                -- Shell
                "shellcheck",
                -- Web
                "eslint_d",
                -- Markup
                "markdownlint",
                -- Build / Infra
                "statix",
                "hadolint",
            },
        },
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost" },
        opts = {
            -- Sorted by language category, then family, then first-appeared.
            linters_by_ft = {
                -- Shell
                sh = { "shellcheck" },
                bash = { "shellcheck" },
                zsh = { "zsh" },
                fish = { "fish" },
                -- Web
                javascript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescript = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                -- python lint handled by ruff LSP (see lang/python.lua)
                -- Markup
                markdown = { "markdownlint" },
                -- Build / Infra
                nix = { "statix" },
                dockerfile = { "hadolint" },
            },
        },
        config = function(_, opts)
            local lint = require("lint")
            lint.linters_by_ft = opts.linters_by_ft

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function()
                    -- Skip special buffers (neo-tree, dashboard, terminals, etc.)
                    if vim.bo.buftype ~= "" then
                        return
                    end
                    lint.try_lint()
                end,
            })
        end,
    },
}
