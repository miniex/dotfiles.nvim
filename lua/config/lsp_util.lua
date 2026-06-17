-- Shared on_attach helpers for lsp/*.lua server configs.
local M = {}

-- Semantic tokens clash with treesitter on some servers; disable on attach
-- (<leader>uy re-enables per buffer).
function M.disable_semantic_tokens(_, bufnr)
    -- Once per buffer: re-disabling on every attach would clobber a <leader>uy toggle.
    if vim.b[bufnr]._semantic_disabled then
        return
    end
    vim.b[bufnr]._semantic_disabled = true
    vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
            pcall(vim.lsp.semantic_tokens.enable, false, { bufnr = bufnr })
        end
    end)
end

return M
