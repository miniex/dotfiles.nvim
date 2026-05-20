return {
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
