-- Requires `just` CLI installed natively (brew/cargo); Mason only provides
-- `just-lsp`, not the runner itself.
return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                just = {},
            },
        },
    },
}
