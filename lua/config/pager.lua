local M = {}

-- View a file in `less` in its own tab — read-only, streamed, no whole-file
-- load. A fresh tab avoids clobbering a special buffer; it closes on quit.
function M.view(file)
    vim.cmd("tabnew | term less -- " .. vim.fn.shellescape(file))
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        once = true,
        callback = function()
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    pcall(vim.api.nvim_buf_delete, buf, { force = true })
                end
            end)
        end,
    })
    vim.cmd("startinsert")
end

return M
