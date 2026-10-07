return {
    require("config.lang").treesitter({ "go", "templ" }),
    -- Registered when nvim-dap loads, not on ft: setup() requires dap (~13ms).
    require("config.dap").spec(function()
        require("dap-go").setup()
    end),
    {
        "leoluz/nvim-dap-go",
        dependencies = { "mfussenegger/nvim-dap" },
        keys = {
            {
                "<leader>dGt",
                function()
                    require("dap-go").debug_test()
                end,
                desc = "Debug Go Test",
                ft = "go",
            },
            {
                "<leader>dGl",
                function()
                    require("dap-go").debug_last_test()
                end,
                desc = "Debug Last Go Test",
                ft = "go",
            },
        },
    },
    -- gopls code actions.
    require("config.lang").code_action_keys("Go", { "o", "X" }, "go"),
}
