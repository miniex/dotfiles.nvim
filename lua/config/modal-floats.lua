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
        for _, d in pairs(M._decorators) do
            if d.open then
                config = d.open(buf, config) or config
            end
        end
        return orig_open(buf, enter, config)
    end

    local orig_set_config = vim.api.nvim_win_set_config
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.api.nvim_win_set_config = function(win, config)
        for _, d in pairs(M._decorators) do
            if d.set_config then
                config = d.set_config(win, config) or config
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

return M
