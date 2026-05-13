return {
    {
        "leoluz/nvim-dap-go",
        ft = "go",
        dependencies = { "mfussenegger/nvim-dap" },
        opts = {},
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
}
