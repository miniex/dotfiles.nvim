return {
    root_markers = { "package.json", "tsconfig.json", ".git" },
    settings = {
        json = {
            validate = { enable = true },
        },
    },
    before_init = function(_, config)
        require("config.lsp_schemastore").json(config)
    end,
}
