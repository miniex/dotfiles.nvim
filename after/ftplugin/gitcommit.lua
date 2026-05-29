-- Commit message ergonomics: 72-col body wrap + spell check.
vim.bo.textwidth = 72
vim.opt_local.spell = true
vim.opt_local.colorcolumn = "51,73" -- subject (50) + body (72) guides
