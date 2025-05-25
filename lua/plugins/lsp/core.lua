local map_key = require("utils.key_mapper").map_key

return {
    {
        "neovim/nvim-lspconfig",
        event = "User FilePost",
        dependencies = {
            "mason.nvim",
            "mason-lspconfig.nvim",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local util = require("lspconfig/util")

            -- c, cpp
            lspconfig.clangd.setup({
                filetypes = { "cuda", "c", "cpp", "objc", "objcpp" },
            })
            -- css
            lspconfig.cssls.setup({})
            lspconfig.somesass_ls.setup({})
            -- javascript + typescript
            lspconfig.ts_ls.setup({})
            -- python
            lspconfig.pyright.setup({})
            -- json
            lspconfig.jsonls.setup({})
            -- lua
            lspconfig.lua_ls.setup({})
            -- markdown
            lspconfig.marksman.setup({})
            -- rust
            lspconfig.rust_analyzer.setup({
                root_dir = util.root_pattern("Cargo.toml"),
                on_attach = function(client, bufnr)
                    client.server_capabilities.didChangeWatchedFilesDynamicRegistration = true
                end,
                settings = {
                    ["rust-analyzer"] = {
                        procMacro = { enable = true },
                        cargo = { allFeatures = true },
                        checkOnSave = {
                            command = "clippy",
                            extraArgs = { "--no-deps" },
                        },
                        files = {
                            watcher = "client",
                        },
                        diagnostics = {
                            disabled = { "inactive-code" },
                        },
                    },
                },
            })
            -- python
            lspconfig.ruff.setup({})
            -- svelte
            lspconfig.svelte.setup({})
            -- toml
            lspconfig.taplo.setup({})
            -- cuda
            lspconfig.neocmake.setup({})

            -- web
            lspconfig.html.setup({})
            lspconfig.htmx.setup({})
            lspconfig.tailwindcss.setup({})

            -- Global mappings
            map_key("K", vim.lsp.buf.hover)
            map_key("gd", vim.lsp.buf.definition)
            map_key("<leader>cc", vim.diagnostic.open_float)
            map_key("<leader>ca", vim.lsp.buf.code_action)
            map_key("gr", vim.lsp.buf.references)
            map_key("gi", vim.lsp.buf.implementation)
            map_key("<leader>rn", vim.lsp.buf.rename)

            -- Global handlers
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover, {
                    border = "rounded",
                }
            )

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                vim.lsp.handlers.signature_help, {
                    border = "rounded",
                }
            )

            -- Diagnostic configuration
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = true,
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufWritePre", "BufNewFile" },
        config = function()
            local conform = require("conform")

            conform.setup({
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            })
        end,
        cmd = "ConformInfo"
    }
}
