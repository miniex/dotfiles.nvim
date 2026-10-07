return {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
        {
            "<leader>rr",
            function()
                require("grug-far").open()
            end,
            desc = "Search & Replace (grug-far)",
        },
        {
            "<leader>rR",
            function()
                require("grug-far").with_visual_selection()
            end,
            mode = "v",
            desc = "Search & Replace selection (grug-far)",
        },
        {
            "<leader>rf",
            function()
                require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
            end,
            desc = "Search & Replace (current file)",
        },
        {
            "<leader>rw",
            function()
                require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
            end,
            desc = "Search & Replace (current word)",
        },
        { "<leader>ri", ":GrugFarWithin<cr>", mode = "v", desc = "Search & Replace within range" },
    },
    opts = {},
}
