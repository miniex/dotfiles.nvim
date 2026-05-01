return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "graphql" })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                graphql = {
                    filetypes = { "graphql", "gql", "typescriptreact", "javascriptreact" },
                },
            },
        },
    },
}
