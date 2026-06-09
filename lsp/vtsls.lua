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
    -- Semantic tokens clash with treesitter here; off by default, <leader>uy re-enables.
    on_attach = function(_, bufnr)
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
                pcall(vim.lsp.semantic_tokens.enable, false, { bufnr = bufnr })
            end
        end)
    end,
    settings = {
        vtsls = {
            experimental = { completion = { enableServerSideFuzzyMatch = true } },
        },
        typescript = common,
        javascript = common,
    },
}
-- Vue hybrid (vtsls on .vue) is wired in lua/plugins/lsp/init.lua via vim.lsp.config().
