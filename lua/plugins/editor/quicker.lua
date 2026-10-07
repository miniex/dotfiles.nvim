-- Editable quickfix + prettier rendering. Pairs with bqf (preview/filter).
return {
    "stevearc/quicker.nvim",
    ft = "qf",
    keys = {
        {
            "<leader>xQ",
            function()
                require("quicker").toggle()
            end,
            desc = "Toggle Quickfix (quicker)",
        },
        {
            "<leader>xL",
            function()
                require("quicker").toggle({ loclist = true })
            end,
            desc = "Toggle Loclist (quicker)",
        },
    },
    opts = {
        keys = {
            {
                ">",
                function()
                    require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                end,
                desc = "Expand quickfix context",
            },
            {
                "<",
                function()
                    require("quicker").collapse()
                end,
                desc = "Collapse quickfix context",
            },
        },
    },
}
