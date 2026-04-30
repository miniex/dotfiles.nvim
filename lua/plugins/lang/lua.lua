return {
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "hrsh7th/nvim-cmp",
        optional = true,
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, 1, { name = "lazydev", group_index = 0 })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                            },
                            codeLens = {
                                enable = true,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            doc = {
                                privateName = { "^_" },
                            },
                            hint = {
                                enable = true,
                                setType = false,
                                paramType = true,
                                paramName = "Disable",
                                semicolon = "Disable",
                                arrayIndex = "Disable",
                            },
                        },
                    },
                },
            },
        },
    },
}
