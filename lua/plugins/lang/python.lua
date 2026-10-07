return {
    require("config.lang").treesitter({ "python" }),
    -- Registered when nvim-dap loads, not on ft: setup() requires dap (~10ms).
    require("config.dap").spec(function()
        local mason_path = require("config.dap").mason_bin("packages/debugpy/venv/bin/python", "debugpy")
        if mason_path then
            require("dap-python").setup(mason_path)
        end
    end),
    {
        "mfussenegger/nvim-dap-python",
        dependencies = { "mfussenegger/nvim-dap" },
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
    require("config.lang").code_action_keys("Python", { "o", "X" }, "python"),
    require("config.lang").mason({ "debugpy" }),
    require("config.lang").neotest("nvim-neotest/neotest-python", function()
        return require("neotest-python")({ runner = "pytest", dap = { justMyCode = false } })
    end),
}
