local M = {}

-- Modal floats are mutually exclusive: opening one closes the others.
-- Auxiliary floats (hover, completion, signature, notifier, flash,
-- snacks.input, which-key) are intentionally absent — they stack.
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
    lazy = "lazy",
    lazy_backdrop = "lazy",
    mason = "mason",
    mason_backdrop = "mason",
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

-- `:checkhealth` renders natively in a float (nvim 0.12 `vim.g.health.style`).
vim.g.health = vim.tbl_deep_extend("force", vim.g.health or {}, { style = "float" })

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
