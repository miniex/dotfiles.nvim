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
-- ui2 owns cmdline; reclaim the row.
opt.cmdheight = 0
-- Set before lualine to avoid dashboard height shift on startup.
opt.laststatus = 3
-- Hidden until bufferline lazy-loads on a real file — no [No Name] flicker before dashboard.
opt.showtabline = 0
opt.scrolloff = 10
opt.smoothscroll = true
opt.mouse:append("a")
opt.autoread = true
opt.undofile = true

-- 0.11+ global default for plugin floats that read vim.o.winborder. fff.nvim
-- only honors preset *names* (single/double/rounded/…); rely on FloatBorder hl
-- (pink, set in globals.lua) for color uniformity even where the shape can't be flowers.
opt.winborder = "rounded"

-- Stable viewport on splits + jumps (no surprise scroll when opening hover/preview).
opt.splitkeep = "screen"
opt.jumpoptions = "view"

-- Smarter diff alignment in fugitive/diffview/gitgraph (0.10+).
opt.diffopt:append("linematch:60")

-- Trusted per-project config (.nvim.lua / .exrc); managed by vim.secure.
opt.exrc = true

-- folding: treesitter expr, start fully expanded (zc/zo to fold/unfold).
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

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
