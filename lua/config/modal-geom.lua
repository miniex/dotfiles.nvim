-- Shared chrome-aware rectangle for every modal float. Mirrors fff's
-- `calculate_layout_dimensions` (picker_ui.lua:396) + its virtual-border +1.
local M = {}

M.RATIO = 0.85

local cache = { key = "", w = 0, h = 0, r = 0, c = 0 }

function M.geom()
    -- No tabline (showtabline=0), so only the statusline eats a row.
    local has_statusline = vim.o.laststatus > 0
    local key = string.format("%d:%d:%d:%s", vim.o.lines, vim.o.columns, vim.o.cmdheight, has_statusline and "T" or "F")
    if cache.key == key then
        return cache.w, cache.h, cache.r, cache.c
    end
    local usable = vim.o.lines - vim.o.cmdheight - (has_statusline and 1 or 0)
    -- Clamp to >=1: a short terminal (large cmdheight) can make usable negative → invalid geometry.
    local h = math.max(1, math.min(math.floor(vim.o.lines * M.RATIO), usable))
    local w = math.max(1, math.floor(vim.o.columns * M.RATIO))
    local r = math.floor((usable - h) / 2) + 1
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

-- Inner rectangle for border'd modals. Spread into a win/preview config + relative.
function M.inner_rect()
    local w, h, r, c = M.geom()
    return { width = w - 2, height = h - 2, row = r, col = c }
end

return M
