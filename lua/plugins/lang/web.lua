return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                vtsls = {},
                cssls = {
                    settings = {
                        css = { validate = true, lint = { unknownAtRules = "ignore" } },
                        scss = { validate = true, lint = { unknownAtRules = "ignore" } },
                        less = { validate = true },
                    },
                },
                html = {
                    filetypes = { "html", "templ" },
                },
                emmet_ls = {
                    filetypes = {
                        "html",
                        "css",
                        "scss",
                        "javascript",
                        "javascriptreact",
                        "typescript",
                        "typescriptreact",
                    },
                },
            },
        },
    },
}
