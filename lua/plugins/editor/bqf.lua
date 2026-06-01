return {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
        auto_enable = true,
        preview = {
            win_height = 12,
            win_vheight = 12,
            border = vim.g.flower_border,
            should_preview_cb = function(bufnr, _)
                -- Skip preview for oversized files and fugitive buffers.
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                return vim.fn.getfsize(bufname) <= 100 * 1024 and not bufname:match("^fugitive://")
            end,
        },
        func_map = {
            drop = "o",
            openc = "O",
            split = "<C-s>",
            vsplit = "<C-v>",
            tab = "t",
            tabb = "T",
            ptogglemode = "z,",
            stoggleup = "K",
        },
        filter = {
            fzf = {
                action_for = { ["ctrl-s"] = "split", ["ctrl-t"] = "tab drop" },
                extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
            },
        },
    },
}
