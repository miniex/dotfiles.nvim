vim.cmd("language en_US.UTF-8")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("configs.diagnostic")
require("configs.globals")
require("configs.keymaps")
require("configs.options")

local plugins = "plugins"
local opts = {}

require("lazy").setup(plugins, opts)
