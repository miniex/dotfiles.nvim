return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                sqls = {
                    filetypes = { "sql", "mysql" },
                },
            },
        },
    },
}
