-- :VenvSelect (global) lives in config/autocmds.lua; buffer-local key only here.
vim.keymap.set("n", "<leader>cv", function()
    require("config.python_venv").select()
end, { buffer = true, desc = "Select Python venv" })
