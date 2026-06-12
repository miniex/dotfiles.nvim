local M = {}

-- View a file in `less` in its own tab — read-only, streamed, no whole-file
-- load. A fresh tab avoids clobbering a special buffer; it closes on quit.
function M.view(file)
    if vim.fn.executable("less") ~= 1 then
        vim.notify("`less` not found on PATH", vim.log.levels.WARN)
        return
    end
    vim.cmd("tabnew")
    local buf = vim.api.nvim_get_current_buf()
    -- argv list → no shell, no cmdline-special expansion (`%`/`#` in the name stay literal).
    vim.fn.jobstart({ "less", "--", file }, { term = true })
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
