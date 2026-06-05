local map = function(lhs, rhs, mode, desc)
    vim.keymap.set(mode or "n", lhs, rhs, { silent = true, desc = desc })
end

-- pane navigation with directional memory (tmux-like return-to-last)
local opposite = { h = "l", l = "h", j = "k", k = "j" }
local return_to = {}
local nav_in_progress = false

vim.api.nvim_create_autocmd("WinEnter", {
    group = vim.api.nvim_create_augroup("PaneNavMemory", { clear = true }),
    callback = function()
        if not nav_in_progress then
            return_to = {}
        end
    end,
})

local function nav(dir)
    nav_in_progress = true
    -- pcall so an error can't leave the flag stuck; schedule the reset so a
    -- deferred WinEnter still sees it set.
    pcall(function()
        local cur = vim.api.nvim_get_current_win()
        local target = return_to[dir]
        if target and vim.api.nvim_win_is_valid(target) and target ~= cur then
            return_to[dir] = nil
            return_to[opposite[dir]] = cur
            vim.api.nvim_set_current_win(target)
        else
            vim.cmd("wincmd " .. dir)
            local now = vim.api.nvim_get_current_win()
            if now ~= cur then
                return_to[opposite[dir]] = cur
            end
        end
    end)
    vim.schedule(function()
        nav_in_progress = false
    end)
end

_G._NavPane = nav

local pane_dir = { h = "left", j = "bottom", k = "top", l = "right" }
for _, dir in ipairs({ "h", "j", "k", "l" }) do
    local desc = "Move to " .. pane_dir[dir] .. " pane"
    map("<C-" .. dir .. ">", function()
        nav(dir)
    end, "n", desc)
    map("<C-" .. dir .. ">", ([[<C-\><C-n><Cmd>lua _NavPane('%s')<CR>]]):format(dir), "t", desc .. " (term)")
end

-- zvzz after jumps. gg/G excluded — races with snacks.scroll (folke/snacks.nvim#2672).
for _, key in ipairs({
    "n",
    "N",
    "*",
    "#",
    "g*",
    "g#",
    "<C-o>",
    "<C-i>",
}) do
    vim.keymap.set("n", key, key .. "zvzz", { silent = true })
end
-- [c/]c are diff-only motions; recenter just in diff mode (they error elsewhere).
for _, key in ipairs({ "[c", "]c" }) do
    vim.keymap.set("n", key, function()
        return vim.wo.diff and key .. "zvzz" or key
    end, { silent = true, expr = true })
end

-- clear search highlight (<Esc> falls back here until multicursor overrides it).
map("<leader>h", ":nohlsearch<CR>", "n", "Clear search highlight")
map("<Esc>", "<cmd>nohlsearch<cr>", "n", "Clear search highlight")

-- indent
map("<", "<gv", "v", "Outdent (keep selection)")
map(">", ">gv", "v", "Indent (keep selection)")

-- save (in buffer group; <leader>w / delete is adjacent)
map("<leader>bs", ":w<CR>", "n", "Save file")

-- delete without yank (D, not d: <leader>d is dap)
map("<leader>D", '"_d', { "n", "x" }, "Delete (no yank)")

-- normal <leader>P left free for the snacks profiler group
map("<leader>p", "p`[v`]=", "n", "Paste + reindent")
map("<leader>p", '"_dP', "x", "Paste over (no yank)")
map("<leader>P", '"_dP`[v`]=', "x", "Paste over + reindent")

-- join keeping cursor position; gJ (no inserted space) on <leader>j
map("J", "mzJ`z", "n", "Join lines (keep cursor)")
map("<leader>j", "gJ", "n", "Join lines (no space)")

-- open URL / file under cursor (netrw's gx is disabled)
map("gx", function()
    local cword = vim.fn.expand("<cWORD>")
    local url = cword:match("https?://[%w%-_%.%?:/%+=&#@!~,;'()%%]+")
    local target = url or vim.fn.expand("<cfile>")
    if target ~= "" then
        vim.ui.open(target)
    end
end, "n", "Open URL/file under cursor")

-- 0.12 built-in undo tree (opt package, needs packadd before first use).
map("<leader>uU", function()
    vim.cmd("packadd nvim.undotree")
    vim.cmd("Undotree")
end, "n", "Toggle undotree")

map("<leader>qR", "<cmd>restart<cr>", "n", "Restart Neovim")

-- View the current file in `less` — read-only, streamed, no whole-file load.
map("<leader>L", function()
    if vim.bo.buftype ~= "" or vim.fn.expand("%:p") == "" then
        vim.notify("Not a file buffer", vim.log.levels.WARN)
        return
    end
    require("config.pager").view(vim.fn.expand("%:p"))
end, "n", "View current file in less")

-- Quickfix stack history (older/newer lists from :grep, LSP, etc.).
map("<leader>x<", "<cmd>colder<cr>", "n", "Quickfix older")
map("<leader>x>", "<cmd>cnewer<cr>", "n", "Quickfix newer")

-- Diagnostics into the native quickfix / loclist (feeds colder/cnewer + bqf).
map("<leader>xE", vim.diagnostic.setqflist, "n", "Diagnostics → quickfix")
map("<leader>xe", vim.diagnostic.setloclist, "n", "Buffer diagnostics → loclist")

-- Yank file path to `+` — absolute / relative / relative:line variants.
local function yank_path(transform)
    local path = transform()
    vim.fn.setreg("+", path)
    vim.notify(path, vim.log.levels.INFO, { title = "yanked path" })
end
map("<leader>yp", function()
    yank_path(function()
        return vim.fn.expand("%:p")
    end)
end, "n", "Yank file path (absolute)")
map("<leader>yP", function()
    yank_path(function()
        return vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
    end)
end, "n", "Yank file path (relative)")
map("<leader>yl", function()
    yank_path(function()
        return vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
    end)
end, "n", "Yank file path:line (relative)")
map("<leader>yg", function()
    require("snacks").gitbrowse({
        what = "permalink",
        open = function(url)
            yank_path(function()
                return url
            end)
        end,
        notify = false,
    })
end, "n", "Yank git permalink (current line)")

-- Buffer nav keymaps live on the bufferline.nvim spec.

-- Last window → bufdelete (keeps bufferline + dashboard in sync); else :quit
-- so split-only closes still work.
local function normal_win_count(buf)
    local n = 0
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if vim.api.nvim_win_get_config(win).relative == "" then
            n = n + 1
        end
    end
    return n
end

local function quit_or_bufdelete(force)
    -- Command-line window forbids buffer switching (bufdelete → E11); just close it.
    if vim.fn.getcmdwintype() ~= "" then
        vim.cmd(force and "quit!" or "quit")
        return
    end
    -- Dashboard has no buffer to close — exit nvim instead.
    if vim.bo.filetype == "snacks_dashboard" then
        vim.cmd(force and "qall!" or "qall")
        return
    end
    if normal_win_count(vim.api.nvim_get_current_buf()) <= 1 then
        require("snacks").bufdelete({ force = force })
    else
        vim.cmd(force and "quit!" or "quit")
    end
end

vim.api.nvim_create_user_command("Q", function(opts)
    quit_or_bufdelete(opts.bang)
end, { bang = true, desc = "Smart quit (bufdelete if last window)" })

vim.api.nvim_create_user_command("WQ", function(opts)
    vim.cmd(opts.bang and "write!" or "write")
    quit_or_bufdelete(opts.bang)
end, { bang = true, desc = "Write + smart quit" })

-- Route only exact `q` / `wq` / `x` / `exit`; the `!` suffix flows through
-- naturally because cnoreabbrev expands on the non-keyword boundary.
vim.cmd([[
    cnoreabbrev <expr> q    (getcmdtype()==':' && getcmdline()=='q')    ? 'Q'  : 'q'
    cnoreabbrev <expr> wq   (getcmdtype()==':' && getcmdline()=='wq')   ? 'WQ' : 'wq'
    cnoreabbrev <expr> x    (getcmdtype()==':' && getcmdline()=='x')    ? 'WQ' : 'x'
    cnoreabbrev <expr> exit (getcmdtype()==':' && getcmdline()=='exit') ? 'WQ' : 'exit'
]])

vim.keymap.set("n", "ZZ", function()
    vim.cmd("write")
    quit_or_bufdelete(false)
end, { silent = true, desc = "Write + smart quit" })

vim.keymap.set("n", "ZQ", function()
    quit_or_bufdelete(true)
end, { silent = true, desc = "Force smart quit" })
