return {
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "ruff.toml",
        ".ruff.toml",
        ".git",
    },
    init_options = {
        settings = { logLevel = "error" },
    },
    -- Hover handled by basedpyright; ruff only for diagnostics + code actions.
    on_attach = function(client, _)
        client.server_capabilities.hoverProvider = false
    end,
}
