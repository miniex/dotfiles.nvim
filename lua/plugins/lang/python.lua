local code_action_only = require("config.lang").code_action_only

return {
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            local mason_path = require("config.dap").mason_bin("packages/debugpy/venv/bin/python", "debugpy")
            if not mason_path then
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
                code_action_only("source.organizeImports"),
                desc = "Python: Organize Imports",
                ft = "python",
            },
            {
                "<leader>cX",
                code_action_only("source.fixAll"),
                desc = "Python: Fix All",
                ft = "python",
            },
        },
    },
}
