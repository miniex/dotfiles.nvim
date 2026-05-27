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
                -- SQL
                "sqlfluff",
                -- YAML
                "yamllint",
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
                -- SQL
                sql = { "sqlfluff" },
                -- YAML
                yaml = { "yamllint" },
            },
        },
        config = function(_, opts)
            local lint = require("lint")
            lint.linters_by_ft = opts.linters_by_ft

            -- Coalesce bursts, keyed per buffer.
            local pending = {}
            local group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
            -- No InsertLeave: save / read only.
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
                group = group,
                callback = function(args)
                    local bufnr = args.buf
                    if vim.bo[bufnr].buftype ~= "" then
                        return
                    end
                    local t = pending[bufnr]
                    if t and not t:is_closing() then
                        t:stop()
                        t:close()
                    end
                    pending[bufnr] = vim.defer_fn(function()
                        pending[bufnr] = nil
                        -- try_lint targets the current buffer; skip if we've moved.
                        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
                            lint.try_lint()
                        end
                    end, 250)
                end,
            })

            vim.api.nvim_create_autocmd("BufWipeout", {
                group = group,
                callback = function(args)
                    local t = pending[args.buf]
                    if t and not t:is_closing() then
                        t:stop()
                        t:close()
                    end
                    pending[args.buf] = nil
                end,
            })
        end,
    },
}
