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

            -- markdownlint's defaults are mostly stylistic nags that bury the rules catching
            -- real mistakes. Disabling via args (not a config file) keeps it cwd-independent;
            -- --stdin must precede --disable, which would otherwise eat it into the rule list.
            lint.linters.markdownlint.args = {
                "--stdin",
                "--disable",
                "MD013", -- line length
                "MD033", -- inline HTML
                "MD041", -- first-line H1
                "MD034", -- bare URLs
                "MD024", -- duplicate headings
                "MD040", -- code fence language required
                "MD036", -- emphasis as heading
                "MD026", -- trailing punctuation in headings
                "MD029", -- ordered-list numbering
                "MD012", -- consecutive blank lines
            }

            -- Drop zsh/fish (interpreter -n linters) when the binary is absent; nvim-lint swallows the error.
            for ft, exe in pairs({ zsh = "zsh", fish = "fish" }) do
                if vim.fn.executable(exe) ~= 1 then
                    opts.linters_by_ft[ft] = nil
                end
            end
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
