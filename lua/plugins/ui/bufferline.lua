-- Tab order uses bufferline's `custom_sort` (buffer-id list), not a `sort_by`
-- comparator: sort_by runs after ui.element bakes the ordinal label, so tabs reorder
-- but the printed "1. 2. …" go stale ("1 2 4 5 3"). custom_sort reorders before the
-- bake, so labels track left-to-right position. New buffers append at the tail;
-- <A-S-h>/<A-S-l> (BufferLineMove*) update custom_sort too.
local named = {} -- cache: name-check each buffer once (custom_filter)

local function order_list()
    local ok, st = pcall(require, "bufferline.state")
    if not ok then
        return nil
    end
    if not st.custom_sort then
        -- First load: seed from the current listed buffers.
        local seed = {}
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[b].buflisted then
                seed[#seed + 1] = b
            end
        end
        st.custom_sort = seed
    end
    return st.custom_sort
end

local function redraw()
    vim.schedule(function()
        if vim.o.showtabline ~= 0 then
            vim.cmd("redrawtabline")
        end
    end)
end

local function track(bufnr)
    if not vim.bo[bufnr].buflisted then
        return
    end
    local list = order_list()
    if not list then
        return
    end
    for _, id in ipairs(list) do
        if id == bufnr then
            return
        end
    end
    list[#list + 1] = bufnr
    redraw()
end

local function untrack(bufnr)
    local list = order_list()
    if not list then
        return
    end
    for i, id in ipairs(list) do
        if id == bufnr then
            table.remove(list, i)
            redraw()
            return
        end
    end
end

-- No tabline in single-file mode (`nvim <file>`), so skip order tracking.
if not vim.g.single_file then
    local group = vim.api.nvim_create_augroup("BufferlineOpenOrder", { clear = true })
    -- BufEnter catches reopened/relisted buffers that BufAdd can miss.
    vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter" }, {
        group = group,
        callback = function(args)
            track(args.buf)
        end,
    })
    vim.api.nvim_create_autocmd("BufDelete", {
        group = group,
        callback = function(args)
            untrack(args.buf)
        end,
    })
    vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        callback = function(args)
            untrack(args.buf)
            named[args.buf] = nil
        end,
    })
end

-- damin 3-stop gradient (matches kitty tab_bar + tmux window list)
local pal = require("config.palette")
local damin_blue = pal.blue
local damin_mid = pal.mid
local damin_pink = pal.pink
local damin_dim = pal.bufferline_dim

-- name_formatter runs per buffer per redraw: a 50ms throttle bounds per-render
-- cost, and a list signature limits `:p` resolution to actual list changes.
-- Tristate so a failed require doesn't retry forever (nil → try, false → give up).
local harpoon_state, harpoon_mod
local pinned, pinned_at, pinned_sig = {}, 0, nil
local function pinned_set()
    local now = vim.uv.hrtime()
    if now - pinned_at < 50 * 1e6 then
        return pinned
    end
    pinned_at = now
    if harpoon_state == nil then
        local ok, mod = pcall(require, "harpoon")
        harpoon_state, harpoon_mod = ok, ok and mod or nil
    end
    if not (harpoon_state and harpoon_mod) then
        return pinned
    end
    local list = harpoon_mod:list()
    local items = list and list.items
    if not items then
        pinned, pinned_sig = {}, nil
        return pinned
    end
    local sig = tostring(#items)
    for _, item in ipairs(items) do
        sig = sig .. "\0" .. (item.value or "")
    end
    if sig == pinned_sig then
        return pinned
    end
    pinned_sig = sig
    pinned = {}
    -- harpoon stores item.value relative to its root (cwd); buf.path is absolute.
    for _, item in ipairs(items) do
        pinned[vim.fn.fnamemodify(item.value, ":p")] = true
    end
    return pinned
end

local buf_jump_keys = {}
for n = 1, 10 do
    local key = n == 10 and "0" or tostring(n)
    table.insert(buf_jump_keys, {
        "<leader>" .. key,
        "<cmd>BufferLineGoToBuffer " .. n .. "<cr>",
        desc = "Go to buffer " .. n,
    })
end

return {
    "akinsho/bufferline.nvim",
    version = "*",
    -- No tab bar in single-file mode (`nvim <file>`): one buffer at a time.
    cond = function()
        return not vim.g.single_file
    end,
    -- Deferred past startup [No Name] so the dashboard appears with a clean top edge.
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
    keys = vim.list_extend(vim.list_extend({}, buf_jump_keys), {
        { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
        { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
        -- S-h/l overrides vim's H/L screen jumps.
        { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
        { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
        -- A-S-h/l reorders the current tab (vs S-h/l, which just moves the cursor).
        { "<A-S-h>", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
        { "<A-S-l>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
        { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer (letter)" },
        { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
    }),
    opts = function()
        local p = pal.mocha()
        return {
            options = {
                mode = "buffers",
                numbers = function(o)
                    -- Visual position (1-based), so a reorder renumbers.
                    return o.ordinal .. "."
                end,
                custom_filter = function(buf)
                    if not named[buf] then
                        if vim.api.nvim_buf_get_name(buf) == "" then
                            return false
                        end
                        named[buf] = true
                    end
                    return true
                end,
                name_formatter = function(buf)
                    return pinned_set()[buf.path] and "♡ " .. buf.name or buf.name
                end,
                always_show_bufferline = true,
                show_buffer_close_icons = true,
                show_close_icon = false,
                show_tab_indicators = false,
                separator_style = { "▏", "▕" },
                indicator = { icon = "▎", style = "icon" },
                diagnostics = "nvim_lsp",
                modified_icon = "●",
                buffer_close_icon = "✗",
                enforce_regular_tabs = true,
                tab_size = 16,
                padding = 1,
                max_name_length = 16,
                max_prefix_length = 10,
                -- Only aerial docks (right); neo-tree is float-only, no offset.
                offsets = {
                    {
                        filetype = "aerial",
                        text = "  Outline",
                        text_align = "left",
                        separator = " ",
                        highlight = "BufferLineOffset",
                    },
                },
            },
            highlights = {
                fill = { bg = "NONE" },
                background = { fg = damin_dim, bg = "NONE", italic = true },
                buffer_selected = {
                    fg = damin_pink,
                    bg = p.surface0,
                    bold = true,
                    italic = false,
                },
                buffer_visible = { fg = damin_mid, bg = "NONE" },
                numbers = { fg = damin_dim, bg = "NONE", italic = true },
                numbers_selected = { fg = damin_pink, bg = p.surface0, bold = true, italic = false },
                numbers_visible = { fg = damin_mid, bg = "NONE" },
                modified = { fg = damin_blue, bg = "NONE" },
                modified_selected = { fg = damin_pink, bg = p.surface0, bold = true },
                modified_visible = { fg = damin_mid, bg = "NONE" },
                duplicate = { fg = damin_dim, bg = "NONE", italic = true },
                duplicate_selected = { fg = damin_pink, bg = p.surface0, italic = true, bold = true },
                duplicate_visible = { fg = damin_mid, bg = "NONE", italic = true },
                separator = { fg = damin_dim, bg = "NONE" },
                separator_selected = { fg = damin_pink, bg = p.surface0 },
                separator_visible = { fg = damin_mid, bg = "NONE" },
                indicator_selected = { fg = damin_pink, bg = p.surface0 },
                close_button = { fg = damin_dim, bg = "NONE" },
                close_button_selected = { fg = damin_pink, bg = p.surface0, bold = true },
                close_button_visible = { fg = damin_mid, bg = "NONE" },
                diagnostic = { fg = damin_dim, bg = "NONE" },
                diagnostic_selected = { fg = p.red, bg = p.surface0, bold = true },
                diagnostic_visible = { fg = p.peach, bg = "NONE" },
                error = { fg = p.red, bg = "NONE" },
                error_selected = { fg = p.red, bg = p.surface0, bold = true },
                warning = { fg = p.yellow, bg = "NONE" },
                warning_selected = { fg = p.yellow, bg = p.surface0, bold = true },
                hint = { fg = damin_blue, bg = "NONE" },
                hint_selected = { fg = damin_blue, bg = p.surface0, bold = true },
                info = { fg = damin_mid, bg = "NONE" },
                info_selected = { fg = damin_mid, bg = p.surface0, bold = true },
                offset_separator = { fg = damin_pink, bg = "NONE" },
            },
        }
    end,
}
