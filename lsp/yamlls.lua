-- filetypes narrowed to "yaml" so helm templates (own filetype) don't attach.
return {
    filetypes = { "yaml" },
    before_init = function(_, config)
        config.settings.yaml.schemas =
            vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
    end,
    settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
            keyOrdering = false,
            format = { enable = true },
            validate = true,
            schemaStore = { enable = false, url = "" },
        },
    },
}
