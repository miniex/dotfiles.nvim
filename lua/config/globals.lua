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
local pink = require("config.palette").pink
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

    -- neo-tree
    setn("NeoTreeNormal")
    setn("NeoTreeNormalNC")
    setn("NeoTreeFloatNormal")
    setb("NeoTreeFloatBorder")
    sett("NeoTreeFloatTitle")

    -- snacks
    for _, k in ipairs({ "Normal", "Border", "Title" }) do
        for _, kind in ipairs({ "Picker", "Notifier", "Input", "Scratch", "Zen", "Terminal", "Dashboard", "" }) do
            local g = "Snacks" .. kind .. k
            if k == "Border" then
                setb(g)
            elseif k == "Title" then
                sett(g)
            else
                setn(g)
            end
        end
    end

    -- which-key
    setn("WhichKeyNormal")
    setn("WhichKeyFloat")
    setb("WhichKeyBorder")
    sett("WhichKeyTitle")

    -- fzf-lua
    setn("FzfLuaNormal")
    setn("FzfLuaPreviewNormal")
    setb("FzfLuaBorder")
    setb("FzfLuaPreviewBorder")
    sett("FzfLuaTitle")
    sett("FzfLuaPreviewTitle")

    -- dropbar
    setn("DropBarMenuNormalFloat")
    setb("DropBarMenuFloatBorder")
    sett("DropBarMenuFloatTitle")

    -- blink.cmp
    setn("BlinkCmpMenu")
    setn("BlinkCmpDoc")
    setn("BlinkCmpSignatureHelp")
    setb("BlinkCmpMenuBorder")
    setb("BlinkCmpDocBorder")
    setb("BlinkCmpSignatureHelpBorder")

    -- bqf preview & nvim-cmp legacy
    setn("BqfPreviewFloat")
    setb("BqfPreviewBorder")
    sett("BqfPreviewTitle")

    -- lazygit (uses LazyGitBorder/LazyGitFloat via winhl override)
    setb("LazyGitBorder")
    setn("LazyGitFloat")

    -- snacks indent guides → muted damin tones (indent dim, scope pink).
    vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#3a2a35" })
    vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = pink })
end
-- ColorScheme fires on the initial catppuccin load too — no eager call needed.
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UnifyFloats", { clear = true }),
    callback = unify_floats,
})
