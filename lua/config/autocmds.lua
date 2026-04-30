-- Auto reload file when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("auto-checktime", { clear = true }),
    command = "checktime",
})

-- WSL2 clipboard sync via clip.exe
local clip = "/mnt/c/Windows/System32/clip.exe"
if vim.fn.executable(clip) == 1 then
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("WSLYank", { clear = true }),
        callback = function()
            local content = table.concat(vim.v.event.regcontents, "\n")
            vim.system({ clip }, { stdin = content })
        end,
    })
end
