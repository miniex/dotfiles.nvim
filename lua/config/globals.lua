vim.g.mapleader = " " -- global leader
vim.g.maplocalleader = " " -- local leader

-- Disable unused providers (skips $PATH scan, ~1-3ms startup).
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Launch modes (read by bufferline / persistence / autocmds):
--  • single_file — one file (`nvim x`): no bufferline/dashboard, one buffer at a time.
--  • file_launch — any file arg(s), incl. `nvim a b c`: no session save/restore.
--  • multi_dir — `nvim dir1 dir2`: per-dir projects; :next/:prev tcd's in.
-- `nvim` is the full IDE; `nvim <dir>` is a bare launch inside <dir> (same session).
do
    local n = vim.fn.argc(-1)
    local function is_dir(i)
        return vim.fn.isdirectory(vim.fn.argv(i)) == 1
    end
    if n == 1 and is_dir(0) then
        -- `nvim <dir>` == `cd <dir> && nvim`: become a bare launch inside <dir> so the
        -- cwd (hence the session key) matches and the same workspace restores.
        vim.fn.chdir(vim.fn.argv(0))
        pcall(vim.cmd, "argdelete *")
        vim.g.single_file, vim.g.file_launch = false, false
        vim.g.dir_launch = vim.fn.getcwd() -- a VimEnter drops the stray dir buffer
    else
        local files = 0
        for i = 0, n - 1 do
            if not is_dir(i) then
                files = files + 1
            end
        end
        vim.g.single_file = n == 1 and files == 1
        vim.g.file_launch = files > 0 -- dirs alone never block the session
        vim.g.multi_dir = n >= 2 and files == 0
    end
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
