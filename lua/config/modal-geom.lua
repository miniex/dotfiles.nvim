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

-- Inner rectangle for border'd modals. Spread into a win/preview config + relative.
function M.inner_rect()
    local w, h, r, c = M.geom()
    return { width = w - 2, height = h - 2, row = r, col = c }
end

-- Scratch modal: nomodifiable `nofile` buffer of `lines` in a centered flower
-- float; `opts.filetype`/`opts.title`; `q`/`<Esc>` close. Returns win, buf.
function M.scratch(lines, opts)
    opts = opts or {}
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].modifiable = false
    if opts.filetype then
        vim.bo[buf].filetype = opts.filetype
    end
    local rect = M.inner_rect()
    rect.relative = "editor"
    rect.border = vim.g.flower_border
    rect.style = "minimal"
    if opts.title then
        rect.title = vim.g.flower_title(opts.title)
        rect.title_pos = "center"
    end
    local win = vim.api.nvim_open_win(buf, true, rect)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
    return win, buf
end

-- Modals whose APIs ignore explicit row/col — snapped on FileType (synchronous,
-- no flash). neo-tree is handled separately (nui nested popup; see VimResized).
local ALIGNED_FT = {
    harpoon = true,
    lazy = true,
    mason = true,
    lazygit = true,
}

if not vim.g._modal_geom_aligner then
    vim.g._modal_geom_aligner = true
    local function snap(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        local win = vim.fn.bufwinid(buf)
        if win == -1 or not vim.api.nvim_win_is_valid(win) then
            return false
        end
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative == "" then
            return true
        end
        local rect = M.inner_rect()
        rect.relative = cfg.relative
        rect.win = cfg.win
        pcall(vim.api.nvim_win_set_config, win, rect)
        return true
    end
    local group = vim.api.nvim_create_augroup("ModalGeomAlign", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
            if not ALIGNED_FT[args.match] then
                return
            end
            -- Defer one tick if the window isn't open yet at FileType time.
            if snap(args.buf) == false then
                vim.schedule(function()
                    snap(args.buf)
                end)
            end
        end,
    })
    -- Re-snap every visible modal on terminal/tmux resize. neo-tree needs
    -- its nui container + inner tree reflowed in lockstep.
    local function resync_all()
        local w, h, r, c = M.geom()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
                local cfg = vim.api.nvim_win_get_config(win)
                if cfg.relative ~= "" then
                    local buf = vim.api.nvim_win_get_buf(win)
                    local ft = vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype or ""
                    if ft == "neo-tree" and cfg.relative == "win" and vim.api.nvim_win_is_valid(cfg.win) then
                        pcall(vim.api.nvim_win_set_config, cfg.win, {
                            relative = "editor",
                            width = w,
                            height = h,
                            row = r + 1,
                            col = c + 1,
                        })
                        pcall(vim.api.nvim_win_set_config, win, {
                            relative = "win",
                            win = cfg.win,
                            row = 1,
                            col = 1,
                            width = w - 2,
                            height = h - 2,
                        })
                    elseif ALIGNED_FT[ft] then
                        local rect = M.inner_rect()
                        rect.relative = cfg.relative
                        rect.win = cfg.win
                        pcall(vim.api.nvim_win_set_config, win, rect)
                    end
                end
            end
        end
    end
    -- Debounce: a drag-resize fires many VimResized; only re-snap once it settles.
    local resize_timer
    vim.api.nvim_create_autocmd("VimResized", {
        group = group,
        callback = function()
            resize_timer = resize_timer or (vim.uv or vim.loop).new_timer()
            resize_timer:start(50, 0, vim.schedule_wrap(resync_all))
        end,
    })
end

return M
