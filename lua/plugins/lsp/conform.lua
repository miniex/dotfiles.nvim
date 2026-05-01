return {
    {
        "williamboman/mason.nvim",
        opts = {
            -- Sorted by language category.
            ensure_installed = {
                -- Shell
                "shfmt",
                -- Systems
                "clang-format",
                "goimports",
                -- Scripting
                "stylua",
                -- Web
                "prettierd",
                -- Database
                "sqlfluff",
                -- Build / Infra
                "cmakelang",
                "nixfmt",
            },
        },
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufWritePre", "BufNewFile" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },
        opts = {
            -- Sorted by language category, then family, then first-appeared.
            formatters_by_ft = {
                -- Shell
                sh = { "shfmt" },
                bash = { "shfmt" },
                fish = { "fish_indent" },
                -- Systems
                c = { "clang-format" },
                cpp = { "clang-format" },
                go = { "goimports" },
                rust = { "rustfmt" },
                -- Scripting
                -- python format handled by ruff LSP via conform's lsp_format fallback
                lua = { "stylua" },
                -- Web
                html = { "prettierd", "prettier", stop_after_first = true },
                css = { "prettierd", "prettier", stop_after_first = true },
                scss = { "prettierd", "prettier", stop_after_first = true },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                -- Database
                sql = { "sqlfluff" },
                -- Data / Config
                json = { "prettierd", "prettier", stop_after_first = true },
                jsonc = { "prettierd", "prettier", stop_after_first = true },
                yaml = { "prettierd", "prettier", stop_after_first = true },
                proto = { "buf" },
                toml = { "taplo" },
                ron = { "rustfmt" },
                -- Markup
                markdown = { "prettierd", "prettier", stop_after_first = true },
                mdx = { "prettierd", "prettier", stop_after_first = true },
                -- Build / Infra
                cmake = { "cmake_format" },
                nix = { "nixfmt" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
            formatters = {
                injected = { options = { ignore_errors = true } },
            },
        },
        init = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
}
