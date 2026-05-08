-- Track each buffer's open order so reopened buffers (vim reuses their bufnr
-- after :bdelete) get a fresh slot at the end instead of snapping back to
-- their original id-based position.
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

return {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
        options = {
            mode = "buffers",
            sort_by = function(buf_a, buf_b)
                return (order[buf_a.id] or math.huge) < (order[buf_b.id] or math.huge)
            end,
            always_show_bufferline = true,
            show_buffer_close_icons = true,
            show_close_icon = false,
            separator_style = "thin",
            indicator = { style = "underline" },
            diagnostics = "nvim_lsp",
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "  Explorer",
                    text_align = "left",
                    separator = true,
                    highlight = "Directory",
                },
            },
        },
    },
}
