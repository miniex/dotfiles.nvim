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
                    -- Get default filetypes from lspconfig
                    local default_filetypes = {
                        "aspnetcorerazor",
                        "astro",
                        "astro-markdown",
                        "blade",
                        "clojure",
                        "django-html",
                        "htmldjango",
                        "edge",
                        "eelixir",
                        "elixir",
                        "ejs",
                        "erb",
                        "eruby",
                        "gohtml",
                        "gohtmltmpl",
                        "haml",
                        "handlebars",
                        "hbs",
                        "html",
                        "html-eex",
                        "heex",
                        "jade",
                        "leaf",
                        "liquid",
                        "mdx",
                        "mustache",
                        "njk",
                        "nunjucks",
                        "php",
                        "razor",
                        "slim",
                        "twig",
                        "css",
                        "less",
                        "postcss",
                        "sass",
                        "scss",
                        "stylus",
                        "sugarss",
                        "javascript",
                        "javascriptreact",
                        "reason",
                        "rescript",
                        "typescript",
                        "typescriptreact",
                        "vue",
                        "svelte",
                    }

                    -- Start with default filetypes
                    opts.filetypes = opts.filetypes or vim.deepcopy(default_filetypes)

                    -- Remove excluded filetypes
                    opts.filetypes = vim.tbl_filter(function(ft)
                        return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
                    end, opts.filetypes)

                    -- Add included filetypes
                    vim.list_extend(opts.filetypes, opts.filetypes_include or {})
                end,
            },
        },
    },
}
