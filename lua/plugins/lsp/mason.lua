-- plugins/lsp/mason.lua
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
                    -- python
                    "ruff",
                    -- svelte
                    "svelte",
                    -- toml
                    "taplo",
                    -- cmake
                    "neocmake",

                    -- web
                    "html",
                    "htmx",
                    "tailwindcss",
                },
            })
        end,
    },
}
