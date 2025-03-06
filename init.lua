vim.cmd("language en_US.UTF-8")

-- Load basic configurations first
require("configs.globals")
require("configs.options")
require("configs.diagnostic")
require("configs.keymaps")

-- Set up lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
local plugins = {
    { import = "plugins.coding" },
    { import = "plugins.editor" },
    { import = "plugins.lsp" },
    { import = "plugins.ui" },
}

-- Lazy.nvim options
local opts = {
    performance = {
        cache = {
            enabled = true,
        },
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
}

-- Initialize lazy.nvim
require("lazy").setup(plugins, opts)

-- WSL2 clip
local clip = '/mnt/c/Windows/System32/clip.exe'

-- Check if clip.exe exists
if vim.fn.executable(clip) == 1 then
    vim.api.nvim_create_autocmd('TextYankPost', {
        group = vim.api.nvim_create_augroup('WSLYank', { clear = true }),
        callback = function()
            local content = table.concat(vim.v.event.regcontents, '\n')
            os.execute(string.format('echo %s | %s', vim.fn.shellescape(content), clip))
        end,
    })
end
