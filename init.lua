-- Hard floor: one clear message instead of cryptic errors deeper in startup.
if vim.fn.has("nvim-0.12") == 0 then
    vim.api.nvim_echo({ { "dotfiles.nvim requires Neovim >= 0.12", "ErrorMsg" } }, true, {})
    return
end

vim.loader.enable() -- bytecode cache for the startup require() chain
pcall(vim.cmd, "language en_US.UTF-8")

require("config.globals")
require("config.options")
require("config.autocmds")
require("config.modal-floats")
require("config.keymaps")
require("config.cursor-bloom")
require("config.lazy")
