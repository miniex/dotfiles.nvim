-- filetypes narrowed to "yaml" so helm templates (own filetype) don't attach.
return {
    filetypes = { "yaml" },
    root_markers = { ".yamllint", ".yamllint.yaml", ".yamllint.yml", ".git" },
    before_init = function(_, config)
        -- Cache the catalog so it isn't rebuilt on every server start / :LspRestart.
        _G._yaml_schemas = _G._yaml_schemas or require("schemastore").yaml.schemas()
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
