return {
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
        end,
    }
}
