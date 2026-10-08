vim.g.mapleader = " " -- global leader
vim.g.maplocalleader = " " -- local leader

-- Disable unused providers (skips $PATH scan, ~1-3ms startup).
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- mason/bin on PATH from the start (not on the lspconfig load tick), so the first
-- buffer's linters (sqlfluff, hadolint, ...) resolve too.
do
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    if not (vim.env.PATH or ""):find(mason_bin, 1, true) then
        vim.env.PATH = mason_bin .. ":" .. (vim.env.PATH or "")
    end
end

-- Stock ftplugins (python/rust/go, …) map [[ ]] buffer-locally, hiding the
-- snacks.words reference jumps. markdown.lua / help.lua ignore this (sections, gO).
vim.g.no_plugin_maps = 1
-- Stock ftplugin/qf.vim would replace the global statusline in the qf window.
vim.g.qf_disable_statusline = 1

-- Launch modes (read by persistence / autocmds / snacks):
--  • `nvim` — full IDE: dashboard + cwd session.
--  • `nvim <dir>` — same as `cd <dir> && nvim` (dir_launch).
--  • anything else (files, several dirs, piped stdin) — file_launch: no session save/restore.
do
    local n = vim.fn.argc(-1)
    if n == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 and pcall(vim.fn.chdir, vim.fn.argv(0)) then
        -- Become a bare launch inside <dir> so the cwd (hence the session key) matches and
        -- the same workspace restores. An inaccessible dir falls through to file_launch.
        pcall(vim.cmd, "argdelete *")
        vim.g.dir_launch = vim.fn.getcwd() -- a VimEnter drops the stray dir buffer
    else
        -- Piped stdin is caught by StdinReadPre (persistence.lua); no ttyin test,
        -- which is also 0 under GUIs (`--embed`).
        vim.g.file_launch = n > 0
    end
end

-- Shared floating-window border: ✿ corners. Used by every plugin that opens a
-- float (LSP hover/signature/diagnostic, snacks, fzf-lua, completion,
-- neotest…) so the whole UI speaks the same visual language.
vim.g.flower_border = { "✿", "─", "✿", "│", "✿", "─", "✿", "│" }
vim.g.flower_title = function(s)
    return " ✿ " .. s .. " ✿ "
end

-- Pin every plugin's float Normal/Border/Title groups to one look.
local palette = require("config.palette")
local pink = palette.pink

-- Snacks splits Normal/Border/Title across many window styles.
local snacks_n, snacks_b, snacks_t = {}, {}, {}
for _, kind in ipairs({ "Picker", "Notifier", "Input", "Scratch", "Zen", "Terminal", "Dashboard", "" }) do
    table.insert(snacks_n, "Snacks" .. kind .. "Normal")
    table.insert(snacks_b, "Snacks" .. kind .. "Border")
    table.insert(snacks_t, "Snacks" .. kind .. "Title")
end

-- Per-plugin float groups (built once): n = Normal, b = Border, t = Title.
local float_groups = {
    Snacks = { n = snacks_n, b = snacks_b, t = snacks_t },
    WhichKey = {
        n = { "WhichKeyNormal" },
        b = { "WhichKeyBorder" },
        t = { "WhichKeyTitle" },
    },
    FzfLua = {
        n = { "FzfLuaNormal", "FzfLuaPreviewNormal" },
        b = { "FzfLuaBorder", "FzfLuaPreviewBorder" },
        t = { "FzfLuaTitle", "FzfLuaPreviewTitle" },
    },
    BlinkCmp = {
        n = { "BlinkCmpMenu", "BlinkCmpDoc", "BlinkCmpSignatureHelp" },
        b = { "BlinkCmpMenuBorder", "BlinkCmpDocBorder", "BlinkCmpSignatureHelpBorder" },
    },
}

local function unify_floats()
    local function setn(name)
        vim.api.nvim_set_hl(0, name, { bg = "NONE" })
    end
    local function setb(name)
        vim.api.nvim_set_hl(0, name, { fg = pink, bg = "NONE" })
    end
    local function sett(name)
        vim.api.nvim_set_hl(0, name, { fg = pink, bg = "NONE", bold = true })
    end

    -- Core
    setn("NormalFloat")
    setb("FloatBorder")
    sett("FloatTitle")
    sett("FloatFooter")

    for _, g in pairs(float_groups) do
        for _, name in ipairs(g.n or {}) do
            setn(name)
        end
        for _, name in ipairs(g.b or {}) do
            setb(name)
        end
        for _, name in ipairs(g.t or {}) do
            sett(name)
        end
    end

    -- snacks indent guides → muted damin tone.
    vim.api.nvim_set_hl(0, "SnacksIndent", { fg = palette.indent })
end
-- ColorScheme fires on the initial catppuccin load too — no eager call needed.
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UnifyFloats", { clear = true }),
    callback = unify_floats,
})
