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
opt.fillchars:append({ eob = " " })

-- etc
opt.encoding = "UTF-8"
opt.cmdheight = 1
-- Set before lualine to avoid dashboard height shift on startup.
opt.laststatus = 3
opt.scrolloff = 10
opt.mouse:append("a")
opt.autoread = true
opt.undofile = true

-- ui2: native floating cmdline/msg (0.12+). `vim.g.disable_ui2=true` to opt out.
if not vim.g.disable_ui2 then
    local ok, ui2 = pcall(require, "vim._core.ui2")
    if ok and ui2.enable then
        ui2.enable({
            enable = true,
            msg = { target = "cmd", timeout = 4000 },
        })
    end
end
