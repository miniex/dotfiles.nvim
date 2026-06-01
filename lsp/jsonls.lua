return {
    root_markers = { "package.json", "tsconfig.json", ".git" },
    settings = {
        json = {
            validate = { enable = true },
        },
    },
    before_init = function(_, config)
        -- Cache once; pcall so a SchemaStore load failure starts schema-less, not erroring.
        if _G._json_schemas == nil then
            local ok, schemas = pcall(function()
                return require("schemastore").json.schemas()
            end)
            _G._json_schemas = ok and schemas or {}
        end
        config.settings.json.schemas = config.settings.json.schemas or {}
        vim.list_extend(config.settings.json.schemas, _G._json_schemas)
    end,
}
