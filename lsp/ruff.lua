return {
    init_options = {
        settings = { logLevel = "error" },
    },
    -- Hover handled by basedpyright; ruff only for diagnostics + code actions.
    on_attach = function(client, _)
        client.server_capabilities.hoverProvider = false
    end,
}
