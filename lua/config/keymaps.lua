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
    nav_in_progress = false
end

_G._NavPane = nav

map("<C-h>", function()
    nav("h")
end, "n", "Move to left pane")
map("<C-j>", function()
    nav("j")
end, "n", "Move to bottom pane")
map("<C-k>", function()
    nav("k")
end, "n", "Move to top pane")
map("<C-l>", function()
    nav("l")
end, "n", "Move to right pane")
map("<C-h>", [[<C-\><C-n><Cmd>lua _NavPane('h')<CR>]], "t", "Move to left pane (term)")
map("<C-j>", [[<C-\><C-n><Cmd>lua _NavPane('j')<CR>]], "t", "Move to bottom pane (term)")
map("<C-k>", [[<C-\><C-n><Cmd>lua _NavPane('k')<CR>]], "t", "Move to top pane (term)")
map("<C-l>", [[<C-\><C-n><Cmd>lua _NavPane('l')<CR>]], "t", "Move to right pane (term)")

-- Re-center cursor after jumps (zv opens folds, zz centers vertically).
for _, key in ipairs({ "n", "N", "*", "#", "g*", "g#", "<C-o>", "<C-i>" }) do
    vim.keymap.set("n", key, key .. "zvzz", { silent = true })
end

-- clear search highlight
map("<leader>h", ":nohlsearch<CR>", "n", "Clear search highlight")

-- indent
map("<", "<gv", "v", "Outdent (keep selection)")
map(">", ">gv", "v", "Indent (keep selection)")

-- save (in buffer group; <leader>w / delete is adjacent)
map("<leader>bs", ":w<CR>", "n", "Save file")

-- delete without yank (D, not d: <leader>d is dap)
map("<leader>D", '"_d', { "n", "x" }, "Delete (no yank)")

-- paste without yank
map("<leader>p", '"_dP', "x", "Paste over (no yank)")

-- paste + reindent (uppercase P; lowercase still belongs to paste-without-yank).
map("<leader>P", "p`[v`]=", "n", "Paste + reindent")
map("<leader>P", '"_dP`[v`]=', "x", "Paste over + reindent")

-- 0.12 built-in undo tree (opt package, needs packadd before first use).
map("<leader>uU", function()
    vim.cmd("packadd nvim.undotree")
    vim.cmd("Undotree")
end, "n", "Toggle undotree")

map("<leader>qR", "<cmd>restart<cr>", "n", "Restart Neovim")

-- Yank file path to `+` — absolute / relative variants.
map("<leader>yp", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify(path, vim.log.levels.INFO, { title = "yanked path" })
end, "n", "Yank file path (absolute)")
map("<leader>yP", function()
    local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
    vim.fn.setreg("+", path)
    vim.notify(path, vim.log.levels.INFO, { title = "yanked path" })
end, "n", "Yank file path (relative)")

-- Buffer nav keymaps live on the bufferline.nvim spec for lazy-load safety.
