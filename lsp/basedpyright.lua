local markers = require("config.lsp_markers")

return {
    root_markers = vim.list_extend(vim.list_extend({}, markers.python), { ".git" }),
    -- Semantic tokens clash with treesitter here; off by default, <leader>uy re-enables.
    on_attach = function(_, bufnr)
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
                pcall(vim.lsp.semantic_tokens.enable, false, { bufnr = bufnr })
            end
        end)
    end,
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
