return {
    {
        "roobert/tailwindcss-colorizer-cmp.nvim",
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                tailwindcss = {
                    filetypes_exclude = { "markdown" },
                    filetypes_include = {},
                    settings = {
                        tailwindCSS = {
                            includeLanguages = {
                                elixir = "html-eex",
                                eelixir = "html-eex",
                                heex = "html-eex",
                            },
                        },
                    },
                },
            },
            setup = {
                tailwindcss = function(_, opts)
                    local tw = require("lspconfig.server_configurations.tailwindcss")

                    if not tw or not tw.default_config then
                        return
                    end

                    opts.filetypes = opts.filetypes or {}
                    vim.list_extend(opts.filetypes, tw.default_config.filetypes or {})
                    opts.filetypes = vim.tbl_filter(function(ft)
                        return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
                    end, opts.filetypes)
                    vim.list_extend(opts.filetypes, opts.filetypes_include or {})
                end,
            },
        },
    },
}

