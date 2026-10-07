-- Code-action picker with a per-action diff preview. Loaded on first <leader>ca
-- (require() in lsp/init.lua on_attach), so fzf-lua stays out of LspAttach.
return {
    "rachartier/tiny-code-action.nvim",
    lazy = true,
    dependencies = { "ibhagwan/fzf-lua" },
    opts = {
        -- "vim" backend needs no external diff binary (delta/difftastic would).
        backend = "vim",
        picker = "fzf-lua",
    },
}
