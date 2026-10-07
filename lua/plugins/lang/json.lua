-- jsonls + json treesitter are wired centrally; SchemaStore is a nvim-lspconfig dependency.
return {
    require("config.lang").treesitter({ "json", "json5" }),
}
