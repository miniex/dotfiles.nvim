return {
    settings = { evenBetterToml = { schema = {} } },
    before_init = function(_, config)
        require("config.lsp_schemastore").toml(config)
    end,
}
