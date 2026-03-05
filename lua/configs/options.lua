local opt = vim.opt

-- tab/indent
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = true
opt.linebreak = true

-- search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- visual
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"

-- etc
opt.encoding = "UTF-8"
opt.cmdheight = 1
opt.scrolloff = 10
opt.mouse:append("a")

-- Auto reload file when changed externally
opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    command = "checktime",
})

-- Auto close hidden buffers that haven't been used for a while
vim.api.nvim_create_autocmd({ "BufHidden" }, {
    callback = function(args)
        local bufnr = args.buf
        vim.defer_fn(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end
            -- Skip if buffer is now visible in a window
            if #vim.fn.win_findbuf(bufnr) > 0 then
                return
            end
            -- Skip modified buffers
            if vim.bo[bufnr].modified then
                return
            end
            -- Skip special buffers (terminals, neo-tree, etc.)
            local buftype = vim.bo[bufnr].buftype
            if buftype ~= "" then
                return
            end
            vim.api.nvim_buf_delete(bufnr, { force = false })
        end, 60000) -- 1 minute after being hidden
    end,
})
