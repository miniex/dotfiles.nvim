local map = function(lhs, rhs, mode, desc)
    vim.keymap.set(mode or "n", lhs, rhs, { silent = true, desc = desc })
end

-- pane navigation
map("<C-h>", "<C-w>h", "n", "Move to left pane")
map("<C-j>", "<C-w>j", "n", "Move to bottom pane")
map("<C-k>", "<C-w>k", "n", "Move to top pane")
map("<C-l>", "<C-w>l", "n", "Move to right pane")
map("<C-h>", [[<C-\><C-n><C-w>h]], "t", "Move to left pane (term)")
map("<C-j>", [[<C-\><C-n><C-w>j]], "t", "Move to bottom pane (term)")
map("<C-k>", [[<C-\><C-n><C-w>k]], "t", "Move to top pane (term)")
map("<C-l>", [[<C-\><C-n><C-w>l]], "t", "Move to right pane (term)")

-- clear search highlight
map("<leader>h", ":nohlsearch<CR>", "n", "Clear search highlight")

-- indent
map("<", "<gv", "v", "Outdent (keep selection)")
map(">", ">gv", "v", "Indent (keep selection)")

-- save
map("<leader>s", ":w<CR>", "n", "Save file")

-- delete without yank
map("<leader>d", '"_d', "n", "Delete (no yank)")
map("<leader>d", '"_d', "x", "Delete (no yank)")

-- paste without yank
map("<leader>p", '"_dP', "x", "Paste over (no yank)")
