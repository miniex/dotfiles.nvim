return {
    {
        "williamboman/mason.nvim",
        opts = { ensure_installed = { "taplo" } },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = { ensure_installed = { "taplo" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                taplo = {
                    settings = {
                        evenBetterToml = {
                            schema = {
                                catalogs = { "https://www.schemastore.org/api/json/catalog.json" },
                                enabled = true,
                            },
                            formatter = {
                                allowedBlankLines = 1,
                                indentTables = false,
                                reorderKeys = false,
                                trailingNewline = true,
                            },
                        },
                    },
                },
            },
        },
    },
}
