return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    init = function()
        -- Auto-restore session when `nvim` opens with no file args and no stdin.
        local group = vim.api.nvim_create_augroup("PersistenceAutoload", { clear = true })
        vim.api.nvim_create_autocmd("StdinReadPre", {
            group = group,
            callback = function()
                vim.g.started_with_stdin = true
            end,
        })
        vim.api.nvim_create_autocmd("VimEnter", {
            group = group,
            nested = true,
            once = true,
            callback = function()
                if vim.fn.argc(-1) > 0 or vim.g.started_with_stdin then
                    return
                end
                require("persistence").load()
            end,
        })
    end,
    keys = {
        {
            "<leader>qs",
            function()
                require("persistence").load()
            end,
            desc = "Restore session for cwd",
        },
        {
            "<leader>qS",
            function()
                require("persistence").select()
            end,
            desc = "Select session",
        },
        {
            "<leader>ql",
            function()
                require("persistence").load({ last = true })
            end,
            desc = "Restore last session",
        },
        {
            "<leader>qd",
            function()
                require("persistence").stop()
            end,
            desc = "Don't save current session",
        },
    },
    opts = {
        options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
    },
}
