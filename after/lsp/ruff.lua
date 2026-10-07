local markers = require("config.lsp_markers")

return {
    root_markers = vim.list_extend(vim.list_extend({}, markers.python), { "ruff.toml", ".ruff.toml", ".git" }),
    init_options = {
        settings = { logLevel = "error" },
    },
    -- Hover handled by basedpyright; ruff only for diagnostics + code actions.
    on_attach = function(client, _)
        client.server_capabilities.hoverProvider = false
    end,
}
