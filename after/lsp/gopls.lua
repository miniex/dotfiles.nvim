return {
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
        gopls = {
            codelenses = {
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
            },
            hints = {
                -- Noisy in dense files; <leader>ci toggles all inlay hints.
                assignVariableTypes = false,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = false,
            },
            analyses = {
                -- Multi-second on large repos; use code-action on demand.
                fieldalignment = false,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
            },
            gofumpt = true,
            usePlaceholders = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-**/node_modules" },
            semanticTokens = true,
        },
    },
}
