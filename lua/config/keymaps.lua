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

-- clear search highlight
map("<leader>h", ":nohlsearch<CR>", "n", "Clear search highlight")

-- indent
map("<", "<gv", "v", "Outdent (keep selection)")
map(">", ">gv", "v", "Indent (keep selection)")

-- save
map("<leader>s", ":w<CR>", "n", "Save file")

-- delete without yank (D, not d: <leader>d is dap)
map("<leader>D", '"_d', "n", "Delete (no yank)")
map("<leader>D", '"_d', "x", "Delete (no yank)")

-- paste without yank
map("<leader>p", '"_dP', "x", "Paste over (no yank)")

-- 0.12 built-in undo tree (opt package, needs packadd before first use).
map("<leader>uU", function()
    vim.cmd("packadd nvim.undotree")
    vim.cmd("Undotree")
end, "n", "Toggle undotree")

-- buffer navigation (bufferline order)
for i = 1, 9 do
    map("<leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", "n", "Go to buffer " .. i)
end
map("[b", ":BufferLineCyclePrev<CR>", "n", "Previous buffer")
map("]b", ":BufferLineCycleNext<CR>", "n", "Next buffer")
