return {
    root_markers = { "package.json", "tsconfig.json", ".git" },
    settings = {
        json = {
            validate = { enable = true },
        },
    },
    before_init = function(_, config)
        config.settings.json.schemas = config.settings.json.schemas or {}
        vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
    end,
}
