local map_key = require("utils.key_mapper").map_key

return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    check_outdated_packages_on_open = true,
                    border = "none",
                    width = 0.8,
                    height = 0.9,
                    icons = {
                        -- ✓ ➜ ✗ ◍
                        package_installed = "◍",
                        package_pending = "➜",
                        package_uninstalled = "◍",
                    },
                },
            })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    -- c, cpp
                    "clangd",
                    -- css
                    "cssls",
                    "somesass_ls",
                    -- javascript + typescript
                    "ts_ls",
                    -- json
                    "jsonls",
                    -- lua
                    "lua_ls",
                    -- markdown
                    "marksman",
                    -- rust
                    "rust_analyzer",
                    -- svelte
                    "svelte",
                    -- toml
                    "taplo",

                    -- web
                    "html",
                    "htmx",
                    "tailwindcss",
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = "User FilePost",
        config = function()
            local lspconfig = require("lspconfig")
            local util = require("lspconfig/util")

            -- c, cpp
            lspconfig.clangd.setup({})
            -- css
            lspconfig.cssls.setup({})
            lspconfig.somesass_ls.setup({})
            -- javascript + typescript
            lspconfig.ts_ls.setup({})
            -- json
            lspconfig.jsonls.setup({})
            -- lua
            lspconfig.lua_ls.setup({})
            -- markdown
            lspconfig.marksman.setup({})
            -- rust
            lspconfig.rust_analyzer.setup({
                root_dir = util.root_pattern("Cargo.toml"),
                settings = {
                    ["rust-analyzer"] = {
                        procMacro = { enable = true },
                        cargo = { allFeatures = true },
                        checkOnSave = {
                            command = "clippy",
                            extraArgs = { "--no-deps" },
                        },
                    },
                },
            })
            -- svelte
            lspconfig.svelte.setup({})
            -- toml
            lspconfig.taplo.setup({})

            -- web
            lspconfig.html.setup({})
            lspconfig.htmx.setup({})
            lspconfig.tailwindcss.setup({})

            -- keymaps
            map_key("K", vim.lsp.buf.hover)
            map_key("gd", vim.lsp.buf.definition)
            map_key("<leader>cc", vim.diagnostic.open_float)
            map_key("<leader>ca", vim.lsp.buf.code_action)
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
