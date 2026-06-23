-- PEP 8 line length (ruff/black default).
vim.opt_local.colorcolumn = "88"

-- :VenvSelect picks the interpreter basedpyright uses (auto-detected otherwise).
if vim.fn.exists(":VenvSelect") == 0 then
    vim.api.nvim_create_user_command("VenvSelect", function()
        require("config.python_venv").select()
    end, { desc = "Select Python venv" })
end

vim.keymap.set("n", "<leader>cv", function()
    require("config.python_venv").select()
end, { buffer = true, desc = "Select Python venv" })
