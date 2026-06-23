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
    -- Raise tsserver heap; the ~3 GB default OOMs on monorepos.
    tsserver = { maxTsServerMemory = 8192 },
    preferences = {
        importModuleSpecifier = "non-relative",
        includePackageJsonAutoImports = "auto",
        preferTypeOnlyAutoImports = true,
    },
    suggest = { completeFunctionCalls = true },
    updateImportsOnFileMove = { enabled = "always" },
}

return {
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
    -- Semantic tokens off centrally (lsp/init.lua).
    settings = {
        vtsls = {
            autoUseWorkspaceTsdk = true,
            experimental = { completion = { enableServerSideFuzzyMatch = true } },
        },
        typescript = common,
        javascript = common,
    },
}
-- Vue hybrid (vtsls on .vue) is wired in lua/plugins/lsp/init.lua via vim.lsp.config().
