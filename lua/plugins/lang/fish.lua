-- LSP in after/lsp/fish_lsp.lua; lint is central.
return {
    require("config.lang").treesitter({ "fish" }),
}
