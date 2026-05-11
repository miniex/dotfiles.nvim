return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "elixir", "heex", "eex" })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                elixirls = {
                    settings = {
                        elixirLS = {
                            dialyzerEnabled = true,
                            dialyzerFormat = "dialyxir_long",
                            enableTestLenses = true,
                            suggestSpecs = true,
                            fetchDeps = false,
                            signatureAfterComplete = true,
                        },
                    },
                },
            },
        },
    },
}
