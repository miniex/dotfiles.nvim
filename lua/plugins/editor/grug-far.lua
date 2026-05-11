return {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
        {
            "<leader>S",
            function()
                require("grug-far").open()
            end,
            desc = "Search & Replace (grug-far)",
        },
        {
            "<leader>S",
            function()
                require("grug-far").with_visual_selection()
            end,
            mode = "v",
            desc = "Search & Replace selection (grug-far)",
        },
        {
            "<leader>cs",
            function()
                require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
            end,
            desc = "Search & Replace (current file)",
        },
    },
    opts = {
        headerMaxWidth = 80,
        keymaps = {
            replace = { n = "<localleader>r" },
            qflist = { n = "<localleader>q" },
            syncLocations = { n = "<localleader>s" },
            syncLine = { n = "<localleader>l" },
            close = { n = "<localleader>c" },
            historyOpen = { n = "<localleader>t" },
            historyAdd = { n = "<localleader>a" },
            refresh = { n = "<localleader>f" },
            openLocation = { n = "<localleader>o" },
            gotoLocation = { n = "<enter>" },
            pickHistoryEntry = { n = "<enter>" },
            abort = { n = "<localleader>b" },
            help = { n = "g?" },
            toggleShowCommand = { n = "<localleader>w" },
            swapEngine = { n = "<localleader>e" },
            previewLocation = { n = "<localleader>i" },
        },
    },
}
