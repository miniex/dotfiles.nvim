local markers = require("config.lsp_markers")

return {
    root_markers = vim.list_extend(vim.list_extend({}, markers.python), { ".git" }),
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "standard",
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                inlayHints = {
                    variableTypes = true,
                    functionReturnTypes = true,
                    callArgumentNames = "partial",
                    pytestParameters = true,
                    genericTypes = false,
                },
            },
        },
    },
}
