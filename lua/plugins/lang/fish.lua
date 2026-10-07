-- LSP: lspconfig defaults; lint is central.
return {
    require("config.lang").treesitter({ "fish" }),
    require("config.lang").lint({ fish = { "fish" } }),
}
