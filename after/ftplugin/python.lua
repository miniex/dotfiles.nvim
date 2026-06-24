-- PEP 8 ruler at the formatter textwidth (format-width); "+0" follows textwidth at
-- draw time, so FileType-autocmd order doesn't matter.
vim.opt_local.colorcolumn = "+0"

-- :VenvSelect (global) lives in config/autocmds.lua; buffer-local key only here.
vim.keymap.set("n", "<leader>cv", function()
    require("config.python_venv").select()
end, { buffer = true, desc = "Select Python venv" })
