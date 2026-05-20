-- Shared chrome-aware rectangle for every modal float. Mirrors fff.nvim's
-- `calculate_layout_dimensions` (picker_ui.lua:396) + its virtual-border +1.
local M = {}

M.RATIO = 0.85

local cache = { key = "", w = 0, h = 0, r = 0, c = 0 }

function M.geom()
    local has_tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
    local has_statusline = vim.o.laststatus > 0
    local key = string.format(
        "%d:%d:%d:%s:%s",
        vim.o.lines,
        vim.o.columns,
        vim.o.cmdheight,
        has_tabline and "T" or "F",
        has_statusline and "T" or "F"
    )
    if cache.key == key then
        return cache.w, cache.h, cache.r, cache.c
    end
    local top_edge = has_tabline and 1 or 0
    local bottom_edge = vim.o.lines - vim.o.cmdheight - (has_statusline and 1 or 0)
    local usable = bottom_edge - top_edge
    local h = math.min(math.floor(vim.o.lines * M.RATIO), usable)
    local w = math.floor(vim.o.columns * M.RATIO)
    local r = top_edge + math.floor((usable - h) / 2) + 1
    local c = math.floor((vim.o.columns - w) / 2)
    cache.key, cache.w, cache.h, cache.r, cache.c = key, w, h, r, c
    return w, h, r, c
end

function M.width()
    local w = select(1, M.geom())
    return w
end

function M.height()
    local h = select(2, M.geom())
    return h
end

function M.row()
    local r = select(3, M.geom())
    return r
end

function M.col()
    local c = select(4, M.geom())
    return c
end

-- Use these as `width`/`height` on windows whose own border eats 2 cells —
-- keeps their visible footprint equal to border="none" modals.
function M.inner_width()
    return M.width() - 2
end

function M.inner_height()
    return M.height() - 2
end

-- Force-align floats whose APIs ignore explicit row/col (harpoon, lazy,
-- mason, lazygit). FileType is synchronous, so the resize lands in the same
-- tick as the open and nvim only renders the final state.
local ALIGNED_FT = {
    harpoon = true,
    lazy = true,
    mason = true,
    lazygit = true,
}

if not vim.g._modal_geom_aligner then
    vim.g._modal_geom_aligner = true
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ModalGeomAlign", { clear = true }),
        callback = function(args)
            if not ALIGNED_FT[args.match] then
                return
            end
            local win = vim.fn.bufwinid(args.buf)
            if win == -1 or not vim.api.nvim_win_is_valid(win) then
                return
            end
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative == "" then
                return
            end
            local w, h, r, c = M.geom()
            pcall(vim.api.nvim_win_set_config, win, {
                relative = cfg.relative,
                win = cfg.win,
                width = w - 2,
                height = h - 2,
                row = r,
                col = c,
            })
        end,
    })
end

return M
