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
        -- Session restore opens buffers before lazy-loaded BufRead listeners
        -- (nvim-lint, nvim-lspconfig, ts-attach) register, so re-fire on LoadPost.
        -- Each listener guards against double-attach.
        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "PersistenceLoadPost",
            callback = function()
                vim.schedule(function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
                            pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = buf, modeline = false })
                            pcall(vim.api.nvim_exec_autocmds, "BufReadPost", { buffer = buf, modeline = false })
                        end
                    end
                end)
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
