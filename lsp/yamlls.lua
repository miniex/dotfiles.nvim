-- filetypes narrowed to "yaml" so helm templates (own filetype) don't attach.
return {
    filetypes = { "yaml" },
    root_markers = { ".yamllint", ".yamllint.yaml", ".yamllint.yml", ".git" },
    before_init = function(_, config)
        -- Cache once; pcall so a SchemaStore load failure starts schema-less, not erroring.
        if _G._yaml_schemas == nil then
            local ok, schemas = pcall(function()
                return require("schemastore").yaml.schemas()
            end)
            _G._yaml_schemas = ok and schemas or {}
        end
        config.settings.yaml.schemas =
            vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, _G._yaml_schemas)
    end,
    settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
            keyOrdering = false,
            validate = true,
            schemaStore = { enable = false, url = "" },
        },
    },
}
