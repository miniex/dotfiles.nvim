local map = function(lhs, rhs, mode, desc)
    vim.keymap.set(mode or "n", lhs, rhs, { silent = true, desc = desc })
end

-- pane navigation
map("<C-h>", "<C-w>h", "n", "Move to left pane")
map("<C-j>", "<C-w>j", "n", "Move to bottom pane")
map("<C-k>", "<C-w>k", "n", "Move to top pane")
map("<C-l>", "<C-w>l", "n", "Move to right pane")

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
