vim.g.mapleader = " " -- global leader
vim.g.maplocalleader = " " -- local leader

-- Disable language providers we don't use. Without these, Neovim scans $PATH
-- for python3 / ruby / perl / node binaries on first `has('python3')` call,
-- adding 1-3ms to startup. We rely on Mason-installed servers, not vim
-- remote plugins.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
