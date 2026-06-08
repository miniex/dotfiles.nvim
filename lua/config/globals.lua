vim.g.mapleader = " " -- global leader
vim.g.maplocalleader = " " -- local leader

-- Disable unused providers (skips $PATH scan, ~1-3ms startup).
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Launch modes (read by bufferline / persistence / autocmds):
--  • single_file — one file (`nvim x`): no bufferline/dashboard, one buffer at a
--    time (opening another wipes the previous).
--  • file_launch — any file arg(s), incl. `nvim a b c`: no session save/restore.
-- Plain `nvim` / `nvim <dir>` are neither — the full IDE with its saved session.
do
    local n = vim.fn.argc(-1)
    local dir = n == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
    vim.g.single_file = n == 1 and not dir
    vim.g.file_launch = n > 0 and not dir
end

-- Shared floating-window border: ✿ corners. Used by every plugin that opens a
-- float (LSP hover/signature/diagnostic, neo-tree, snacks, fzf-lua, completion,
-- dropbar, bqf, neotest…) so the whole UI speaks the same visual language.
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
    NeoTree = {
        n = { "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeFloatNormal" },
        b = { "NeoTreeFloatBorder" },
        t = { "NeoTreeFloatTitle" },
    },
    Snacks = { n = snacks_n, b = snacks_b, t = snacks_t },
    WhichKey = {
        n = { "WhichKeyNormal", "WhichKeyFloat" },
        b = { "WhichKeyBorder" },
        t = { "WhichKeyTitle" },
    },
    FzfLua = {
        n = { "FzfLuaNormal", "FzfLuaPreviewNormal" },
        b = { "FzfLuaBorder", "FzfLuaPreviewBorder" },
        t = { "FzfLuaTitle", "FzfLuaPreviewTitle" },
    },
    DropBar = {
        n = { "DropBarMenuNormalFloat" },
        b = { "DropBarMenuFloatBorder" },
        t = { "DropBarMenuFloatTitle" },
    },
    BlinkCmp = {
        n = { "BlinkCmpMenu", "BlinkCmpDoc", "BlinkCmpSignatureHelp" },
        b = { "BlinkCmpMenuBorder", "BlinkCmpDocBorder", "BlinkCmpSignatureHelpBorder" },
    },
    -- bqf preview & nvim-cmp legacy
    Bqf = {
        n = { "BqfPreviewFloat" },
        b = { "BqfPreviewBorder" },
        t = { "BqfPreviewTitle" },
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

    -- snacks indent guides → muted damin tones (indent dim, scope pink).
    vim.api.nvim_set_hl(0, "SnacksIndent", { fg = palette.indent })
    vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = pink })
    vim.api.nvim_set_hl(0, "SnacksIndentChunk", { fg = pink })
end
-- ColorScheme fires on the initial catppuccin load too — no eager call needed.
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UnifyFloats", { clear = true }),
    callback = unify_floats,
})
