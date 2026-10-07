return {
    root_markers = { ".yamllint", ".yamllint.yaml", ".yamllint.yml", ".git" },
    before_init = function(_, config)
        require("config.lsp_schemastore").yaml(config)
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
