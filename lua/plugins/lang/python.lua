return {
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
            if vim.fn.executable(mason_path) ~= 1 then
                vim.schedule(function()
                    vim.notify(
                        "debugpy not found at " .. mason_path .. "\nRun :MasonInstall debugpy",
                        vim.log.levels.WARN,
                        { title = "nvim-dap-python" }
                    )
                end)
                return
            end
            require("dap-python").setup(mason_path)
        end,
        keys = {
            {
                "<leader>dPt",
                function()
                    require("dap-python").test_method()
                end,
                desc = "Debug Python Test Method",
                ft = "python",
            },
            {
                "<leader>dPc",
                function()
                    require("dap-python").test_class()
                end,
                desc = "Debug Python Test Class",
                ft = "python",
            },
        },
    },
    {
        -- Ruff code actions (mirrors lang/web.lua for TS).
        "neovim/nvim-lspconfig",
        keys = {
            {
                "<leader>cI",
                function()
                    vim.lsp.buf.code_action({
                        context = { only = { "source.organizeImports" }, diagnostics = {} },
                        apply = true,
                    })
                end,
                desc = "Python: Organize Imports",
                ft = "python",
            },
            {
                "<leader>cX",
                function()
                    vim.lsp.buf.code_action({
                        context = { only = { "source.fixAll" }, diagnostics = {} },
                        apply = true,
                    })
                end,
                desc = "Python: Fix All",
                ft = "python",
            },
        },
    },
}
