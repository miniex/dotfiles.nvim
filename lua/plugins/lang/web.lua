return {
    {
        "williamboman/mason.nvim",
        opts = { ensure_installed = { "css-lsp", "html-lsp", "emmet-ls" } },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = { ensure_installed = { "cssls", "html", "emmet_ls" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
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
