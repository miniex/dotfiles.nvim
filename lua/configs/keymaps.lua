local map = function(lhs, rhs, mode)
    vim.keymap.set(mode or "n", lhs, rhs, { noremap = true, silent = true })
end

-- pane navigation
map("<C-h>", "<C-w>h")
map("<C-j>", "<C-w>j")
map("<C-k>", "<C-w>k")
map("<C-l>", "<C-w>l")

-- clear search highlight
map("<leader>h", ":nohlsearch<CR>")

-- indent
map("<", "<gv", "v")
map(">", ">gv", "v")

-- save
map("<leader>s", ":w<CR>")

-- delete without yank
map("<leader>d", '"_d', "n")
map("<leader>d", '"_d', "x")

-- paste without yank
map("<leader>p", '"_dP', "x")
