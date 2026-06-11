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
        -- Empty `enew`-only sessions trample the dashboard; only restore real files.
        local function session_has_files()
            local ok, result = pcall(function()
                local file = require("persistence").current()
                if vim.fn.filereadable(file) == 0 then
                    return false
                end
                -- A fileless session is tiny; skip reading a large one (it has files).
                if vim.fn.getfsize(file) > 256 * 1024 then
                    return true
                end
                for _, line in ipairs(vim.fn.readfile(file)) do
                    if line:match("^badd ") or line:match("^edit ") then
                        return true
                    end
                end
                return false
            end)
            return ok and result or false
        end
        vim.api.nvim_create_autocmd("VimEnter", {
            group = group,
            nested = true,
            once = true,
            callback = function()
                if
                    vim.fn.argc(-1) > 0
                    or vim.g.started_with_stdin
                    or #vim.api.nvim_list_uis() == 0
                    or not session_has_files()
                then
                    return
                end
                require("persistence").load()
            end,
        })
        -- Re-fire BufRead listeners (lint, lspconfig, ts-attach) on restored buffers.
        -- nvim_buf_call sets current-buf so runtime ftplugins that use `0` (e.g.
        -- ftplugin/lua.lua → treesitter.start()) target the right buf.
        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "PersistenceLoadPost",
            callback = function()
                vim.schedule(function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
                            pcall(vim.api.nvim_buf_call, buf, function()
                                vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
                                vim.api.nvim_exec_autocmds("BufReadPost", { buffer = buf, modeline = false })
                            end)
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
        options = { "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
        -- Per-branch sessions (branch name appended, except main/master).
        branch = true,
    },
    config = function(_, opts)
        require("persistence").setup(opts)
        -- Don't overwrite the workspace session from a headless run (CI, scripts),
        -- a file launch (`nvim file…`), or stdin — none are the project session.
        if #vim.api.nvim_list_uis() == 0 or vim.g.file_launch or vim.g.started_with_stdin then
            require("persistence").stop()
        end
    end,
}
