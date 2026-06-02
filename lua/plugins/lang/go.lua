local code_action_only = require("config.lang").code_action_only

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
    {
        -- gopls code actions (mirrors lang/python.lua for Ruff).
        "neovim/nvim-lspconfig",
        keys = {
            {
                "<leader>cI",
                code_action_only("source.organizeImports"),
                desc = "Go: Organize Imports",
                ft = "go",
            },
            {
                "<leader>cX",
                code_action_only("source.fixAll"),
                desc = "Go: Fix All",
                ft = "go",
            },
        },
    },
}
