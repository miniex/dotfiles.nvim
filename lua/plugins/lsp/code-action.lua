-- Code-action picker with a per-action diff preview. Triggered from <leader>ca
-- (mapped in lsp/init.lua on_attach).
return {
    "rachartier/tiny-code-action.nvim",
    event = "LspAttach",
    dependencies = { "ibhagwan/fzf-lua" },
    opts = {
        -- "vim" backend needs no external diff binary (delta/difftastic would).
        backend = "vim",
        picker = "fzf-lua",
    },
}
