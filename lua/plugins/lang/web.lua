-- JS/TS code-action shortcuts. `source.*` kinds are LSP-standard (no VtslsExec needed).
local function code_action_only(kind)
    return function()
        vim.lsp.buf.code_action({
            context = { only = { kind }, diagnostics = {} },
            apply = true,
        })
    end
end

local ts_fts = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

return {
    "neovim/nvim-lspconfig",
    keys = {
        {
            "<leader>cI",
            code_action_only("source.organizeImports"),
            desc = "TS: Organize Imports",
            ft = ts_fts,
        },
        {
            "<leader>cU",
            code_action_only("source.removeUnused"),
            desc = "TS: Remove Unused",
            ft = ts_fts,
        },
    },
}
