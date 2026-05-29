return {
    root_markers = { "package.json", "tsconfig.json", ".git" },
    settings = {
        json = {
            validate = { enable = true },
        },
    },
    before_init = function(_, config)
        -- Cache the catalog so it isn't rebuilt on every server start / :LspRestart.
        _G._json_schemas = _G._json_schemas or require("schemastore").json.schemas()
        config.settings.json.schemas = config.settings.json.schemas or {}
        vim.list_extend(config.settings.json.schemas, _G._json_schemas)
    end,
}
