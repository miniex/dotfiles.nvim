local opt = vim.opt

-- tab/indent
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = true
opt.linebreak = true
-- Keep wrapped lines under their indent, with a continuation marker.
opt.breakindent = true
opt.showbreak = "↪ "

-- search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
-- live :s/.../ preview; :grep backed by ripgrep
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

-- visual
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes:2"
opt.fillchars:append({ eob = " " })
-- block-wise visual edits past line end (column / table editing)
opt.virtualedit = "block"
-- whitespace shown on demand; toggle with <leader>ui
opt.list = false
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }

-- undofile covers recovery; skip swap/backup files.
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.pumheight = 10
-- ui2 owns cmdline; reclaim the row.
opt.cmdheight = 0
-- Set before lualine to avoid dashboard height shift on startup.
opt.laststatus = 3
-- Hidden until bufferline lazy-loads on a real file — no [No Name] flicker before dashboard.
opt.showtabline = 0
-- Safety net for the first-`<leader>` lag while which-key triggers register.
opt.timeoutlen = 300
-- CursorHold idle for document_highlight + lightbulb.
opt.updatetime = 300
opt.scrolloff = 10
-- snacks.scroll owns scroll; built-in would double-fire.
opt.smoothscroll = false
opt.mouse:append("a")
opt.autoread = true
opt.undofile = true

-- 0.11+ global default for floats reading vim.o.winborder. Plugins that only accept
-- preset *names* ignore custom flower chars — "rounded" + pink FloatBorder hl keeps color uniform.
opt.winborder = "rounded"

-- Stable viewport on splits + jumps (no surprise scroll when opening hover/preview).
opt.splitkeep = "screen"
opt.jumpoptions = "view"

-- Smarter diff: histogram hunks + line alignment (0.10) + word-level inline highlight (0.12).
opt.diffopt:append("algorithm:histogram")
opt.diffopt:append("linematch:60")
opt.diffopt:append("inline:word")

-- Trusted per-project config (.nvim.lua / .exrc); managed by vim.secure.
opt.exrc = true

-- Prompt to save on :q/:bd with unsaved changes.
opt.confirm = true

-- camelCase-aware spell (enabled per-filetype in autocmds.lua, not globally).
opt.spelloptions = "camel"

-- Folding disabled.
opt.foldenable = false

-- ui2: native floating cmdline/msg (0.12+). `vim.g.disable_ui2=true` to opt out.
if not vim.g.disable_ui2 then
    local ok, ui2 = pcall(require, "vim._core.ui2")
    if ok and ui2.enable then
        pcall(ui2.enable, {
            enable = true,
            msg = { target = "cmd", timeout = 4000 },
        })
    end
end
