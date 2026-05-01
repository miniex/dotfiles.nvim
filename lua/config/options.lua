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
opt.signcolumn = "yes:2"

-- etc
opt.encoding = "UTF-8"
opt.cmdheight = 1
-- Match lualine's globalstatus before any plugin loads so the dashboard's
-- initial height calc doesn't shift by one row when lualine flips it later.
opt.laststatus = 3
opt.scrolloff = 10
opt.mouse:append("a")
opt.autoread = true
opt.undofile = true
