-- Inlay hint kinds shown when hints are enabled (on by default; `<leader>ci` toggles).
local hints = {
    parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
    variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
    propertyDeclarationTypes = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    parameterTypes = { enabled = true },
    enumMemberValues = { enabled = true },
}

local common = {
    inlayHints = hints,
    preferences = {
        importModuleSpecifier = "non-relative",
        includePackageJsonAutoImports = "auto",
    },
    suggest = { completeFunctionCalls = true },
    updateImportsOnFileMove = { enabled = "always" },
}

return {
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
    settings = {
        vtsls = {
            experimental = { completion = { enableServerSideFuzzyMatch = true } },
        },
        typescript = common,
        javascript = common,
    },
}
