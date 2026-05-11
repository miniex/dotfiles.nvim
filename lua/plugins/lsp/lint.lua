return {
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            ensure_installed = {
                -- Shell
                "shellcheck",
                -- Go
                "golangci-lint",
                -- Lua
                "selene",
                -- JavaScript/TS
                "eslint_d",
                -- Markdown
                "markdownlint",
                -- Nix
                "statix",
                -- Dockerfile
                "hadolint",
            },
        },
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost" },
        opts = {
            linters_by_ft = {
                -- Shell
                sh = { "shellcheck" },
                bash = { "shellcheck" },
                -- Zsh
                zsh = { "zsh" },
                -- Fish
                fish = { "fish" },
                -- Go
                go = { "golangcilint" },
                -- python lint handled by ruff LSP (see lang/python.lua)
                -- Lua
                lua = { "selene" },
                -- JavaScript/TS
                javascript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescript = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                -- Markdown
                markdown = { "markdownlint" },
                -- Nix
                nix = { "statix" },
                -- Dockerfile
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
