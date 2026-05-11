return {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
        auto_enable = true,
        preview = {
            win_height = 12,
            win_vheight = 12,
            border = "rounded",
            should_preview_cb = function(bufnr, _)
                local ret = true
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                local fsize = vim.fn.getfsize(bufname)
                if fsize > 100 * 1024 then
                    ret = false
                elseif bufname:match("^fugitive://") then
                    ret = false
                end
                return ret
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
