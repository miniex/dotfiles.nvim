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
    -- Ruff code actions.
    require("config.lang").code_action_keys("Python", { "I", "X" }, "python"),
}
