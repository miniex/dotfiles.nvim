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
        opts = {
            buflisted = false,
            number = false,
            relativenumber = false,
            signcolumn = "auto",
            winfixheight = true,
            wrap = false,
        },
        edit = {
            enabled = true,
            autosave = "unmodified",
        },
        constrain_cursor = true,
        highlight = {
            treesitter = true,
            lsp = true,
            load_buffers = false,
        },
        follow = { enabled = false },
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
