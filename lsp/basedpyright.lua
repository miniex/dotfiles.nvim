local markers = require("config.lsp_markers")

return {
    root_markers = vim.list_extend(vim.list_extend({}, markers.python), { ".git" }),
    settings = {
        basedpyright = {
            -- Cede import organizing to ruff (avoids a duplicate organize-imports action).
            disableOrganizeImports = true,
            analysis = {
                typeCheckingMode = "standard",
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                inlayHints = {
                    variableTypes = true,
                    functionReturnTypes = true,
                    callArgumentNames = true,
                    genericTypes = false,
                },
            },
        },
    },
}
