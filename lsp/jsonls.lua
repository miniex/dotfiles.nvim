return {
    settings = {
        json = {
            format = { enable = true },
            validate = { enable = true },
        },
    },
    before_init = function(_, config)
        config.settings.json.schemas = config.settings.json.schemas or {}
        vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
    end,
}
