local M = {}

-- One shared `nvim_open_win` / `nvim_win_set_config` patch. Plugins register
-- a named decorator instead of wrapping the APIs themselves. Each decorator
-- returns a modified config or nil to leave it alone.
M._decorators = M._decorators or {}

function M.add_decorator(name, spec)
    M._decorators[name] = spec
end

if not vim.g._modal_float_api_patched then
    vim.g._modal_float_api_patched = true
    local orig_open = vim.api.nvim_open_win
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_open_win = function(buf, enter, config)
        -- Hot path (completion/hover open floats per keystroke): skip when no
        -- decorator is registered.
        if next(M._decorators) ~= nil then
            for _, d in pairs(M._decorators) do
                if d.open then
                    -- pcall so one decorator can't break the chain.
                    local ok, result = pcall(d.open, buf, config)
                    if ok then
                        config = result or config
                    end
                end
            end
        end
        return orig_open(buf, enter, config)
    end

    local orig_set_config = vim.api.nvim_win_set_config
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_win_set_config = function(win, config)
        if next(M._decorators) ~= nil then
            for _, d in pairs(M._decorators) do
                if d.set_config then
                    local ok, result = pcall(d.set_config, win, config)
                    if ok then
                        config = result or config
                    end
                end
            end
        end
        return orig_set_config(win, config)
    end
end

-- Modal floats are mutually exclusive: opening one closes the others.
-- Auxiliary floats (hover, completion, signature, notifier, fidget, flash,
-- dropbar, snacks.input, which-key) are intentionally absent — they stack.
-- Sidebar/split UIs fall through is_floating().
local OWNER = {
    fzf = "fzf",
    fzflua_backdrop = "fzf",
    fff_input = "fff",
    fff_list = "fff",
    fff_preview = "fff",
    fff_file_info = "fff",
    snacks_picker_input = "snacks_picker",
    snacks_picker_list = "snacks_picker",
    snacks_terminal = "snacks_terminal",
    harpoon = "harpoon",
    lazy = "lazy",
    lazy_backdrop = "lazy",
    mason = "mason",
    mason_backdrop = "mason",
    ["neo-tree"] = "neo-tree",
    ["neo-tree-popup"] = "neo-tree",
    checkhealth = "checkhealth",
}

local function is_floating(win)
    return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative ~= ""
end

local function close_other_owners(keep_owner, keep_win)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if win ~= keep_win and is_floating(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_is_valid(buf) then
                local o = OWNER[vim.bo[buf].filetype]
                if o and o ~= keep_owner then
                    pcall(vim.api.nvim_win_close, win, true)
                end
            end
        end
    end
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("modal-floats", { clear = true }),
    callback = function(args)
        local new_owner = OWNER[args.match]
        if not new_owner then
            return
        end
        -- Defer: window not yet attached when FileType fires.
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(args.buf) then
                return
            end
            local win = vim.fn.bufwinid(args.buf)
            if win == -1 or not is_floating(win) then
                return
            end
            close_other_owners(new_owner, win)
        end)
    end,
})

-- `:checkhealth` renders natively in a float (nvim 0.12 `vim.g.health.style`) — no report
-- tab to flash. That float is a `vim.lsp.util.open_floating_preview`; a flag around _check
-- lets the decorator claim it and stamp our modal geometry onto its config at creation.
vim.g.health = vim.tbl_deep_extend("force", vim.g.health or {}, { style = "float" })

local building_health = false
local health_buf -- the report preview's buffer, claimed on its open
local function style_health(config)
    local rect = require("config.modal-geom").inner_rect()
    -- Force editor-relative NW anchoring: open_floating_preview anchors to the cursor, so
    -- without this our row/col get read against a SW/SE anchor and the float flies top-left.
    config.relative = "editor"
    config.win = nil
    config.bufpos = nil
    config.anchor = "NW"
    config.row, config.col = rect.row, rect.col
    config.width, config.height = rect.width, rect.height
    config.border = vim.g.flower_border
    config.title = vim.g.flower_title("checkhealth")
    config.title_pos = "center"
    return config
end
M.add_decorator("checkhealth", {
    -- The report preview is the first editor float _check opens; claim its buffer so we
    -- style only it — not ui2's progress-message float, which also moves during the run.
    open = function(buf, c)
        if building_health and not health_buf and c.relative ~= "" then
            health_buf = buf
        end
        if buf == health_buf then
            return style_health(c)
        end
    end,
    set_config = function(win, c)
        if health_buf and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == health_buf then
            return style_health(c)
        end
    end,
})

local health = require("vim.health")
local orig_check = health._check
---@diagnostic disable-next-line: duplicate-set-field
health._check = function(mods, plugin_names)
    health_buf = nil
    building_health = true
    local ok, err = pcall(orig_check, mods, plugin_names)
    building_health = false
    if not ok then
        error(err, 0)
    end
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("modal-floats-checkhealth", { clear = true }),
    pattern = "checkhealth",
    callback = function(args)
        local win = vim.fn.bufwinid(args.buf)
        if win == -1 or not is_floating(win) then
            return
        end
        vim.wo[win].winhighlight =
            "Normal:NormalFloat,NormalNC:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle"
        vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = args.buf, silent = true })
    end,
})

return M
