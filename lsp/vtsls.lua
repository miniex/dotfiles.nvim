-- Inlay hints stay hidden until `<leader>ci` toggles them on.
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
    settings = {
        vtsls = {
            experimental = { completion = { enableServerSideFuzzyMatch = true } },
        },
        typescript = common,
        javascript = common,
    },
}
