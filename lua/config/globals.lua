vim.g.mapleader = " " -- global leader
vim.g.maplocalleader = " " -- local leader

-- Disable unused providers (skips $PATH scan, ~1-3ms startup).
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

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
end
-- ColorScheme fires on the initial catppuccin load too — no eager call needed.
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UnifyFloats", { clear = true }),
    callback = unify_floats,
})
