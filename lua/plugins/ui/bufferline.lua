-- Track open order so reopened buffers (reused bufnr) get a fresh tail slot.
local order_counter = 0
local order = {}

local function ensure_order(bufnr)
    if not order[bufnr] then
        order_counter = order_counter + 1
        order[bufnr] = order_counter
    end
end

local group = vim.api.nvim_create_augroup("BufferlineOpenOrder", { clear = true })

vim.api.nvim_create_autocmd("BufAdd", {
    group = group,
    callback = function(args)
        if vim.bo[args.buf].buflisted then
            ensure_order(args.buf)
        end
    end,
})

vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
        order[args.buf] = nil
    end,
})

for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted then
        ensure_order(b)
    end
end

-- damin 3-stop gradient (matches kitty tab_bar + tmux window list)
local damin_blue = "#98ABCC"
local damin_mid = "#C09DBE"
local damin_pink = "#E890B0"
local damin_dim = "#6E7A95"

-- ♡ trail on harpoon-pinned buffers.
local function harpoon_pinned(path)
    local ok, harpoon = pcall(require, "harpoon")
    if not ok then
        return false
    end
    local list = harpoon:list()
    if not list or not list.items then
        return false
    end
    for _, item in ipairs(list.items) do
        if item.value == path then
            return true
        end
    end
    return false
end

return {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    opts = function()
        local p = require("catppuccin.palettes").get_palette("mocha")
        return {
            options = {
                mode = "buffers",
                sort_by = function(buf_a, buf_b)
                    return (order[buf_a.id] or math.huge) < (order[buf_b.id] or math.huge)
                end,
                custom_filter = function(buf)
                    return vim.api.nvim_buf_get_name(buf) ~= ""
                end,
                name_formatter = function(buf)
                    return harpoon_pinned(buf.path) and "♡ " .. buf.name or buf.name
                end,
                always_show_bufferline = true,
                show_buffer_close_icons = true,
                show_close_icon = false,
                show_tab_indicators = false,
                separator_style = "thin",
                indicator = { style = "underline" },
                diagnostics = "nvim_lsp",
                modified_icon = "✿",
                buffer_close_icon = "✗",
            },
            -- 3-stop gradient: selected = pink (active), visible = mid, normal = blue (dim).
            highlights = {
                fill = { bg = "NONE" },
                background = { fg = damin_dim, bg = "NONE" },
                buffer_selected = { fg = damin_pink, bg = "NONE", bold = true, italic = false },
                buffer_visible = { fg = damin_mid, bg = "NONE" },
                modified = { fg = damin_blue, bg = "NONE" },
                modified_selected = { fg = damin_pink, bg = "NONE" },
                modified_visible = { fg = damin_mid, bg = "NONE" },
                duplicate = { fg = damin_dim, bg = "NONE", italic = true },
                duplicate_selected = { fg = damin_pink, bg = "NONE", italic = true, bold = true },
                duplicate_visible = { fg = damin_mid, bg = "NONE", italic = true },
                separator = { fg = damin_dim, bg = "NONE" },
                separator_selected = { fg = damin_pink, bg = "NONE" },
                separator_visible = { fg = damin_mid, bg = "NONE" },
                indicator_selected = { fg = damin_pink, bg = "NONE" },
                close_button = { fg = damin_dim, bg = "NONE" },
                close_button_selected = { fg = damin_pink, bg = "NONE" },
                close_button_visible = { fg = damin_mid, bg = "NONE" },
                diagnostic = { fg = damin_dim, bg = "NONE" },
                diagnostic_selected = { fg = p.red, bg = "NONE", bold = true },
                diagnostic_visible = { fg = p.peach, bg = "NONE" },
                error = { fg = p.red, bg = "NONE" },
                error_selected = { fg = p.red, bg = "NONE", bold = true },
                warning = { fg = p.yellow, bg = "NONE" },
                warning_selected = { fg = p.yellow, bg = "NONE", bold = true },
            },
        }
    end,
}
