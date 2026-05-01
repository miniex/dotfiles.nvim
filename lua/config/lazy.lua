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

local spec = {
    { import = "plugins.coding" },
    { import = "plugins.editor" },
    { import = "plugins.lsp" },
    { import = "plugins.ui" },
}
for name, enabled in pairs(require("config.langs")) do
    if enabled then
        table.insert(spec, { import = "plugins.lang." .. name })
    end
end

require("lazy").setup({
    spec = spec,
    -- Skip scanning the cwd for project-local `.lazy.lua` specs; we don't
    -- use them, so this avoids a per-startup filesystem stat.
    local_spec = false,
    -- Don't notify on plugin file changes during the session.
    change_detection = { notify = false },
    -- Don't fetch READMEs.
    readme = { enabled = false },
    performance = {
        cache = { enabled = true },
        reset_packpath = true,
        rtp = {
            -- Reduce rtp to $VIMRUNTIME + this config only. Plugin paths are
            -- prepended on demand by lazy.nvim itself.
            reset = true,
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
                "rplugin",
                "spellfile_plugin",
                "man",
                "editorconfig",
                "health",
            },
        },
    },
})
