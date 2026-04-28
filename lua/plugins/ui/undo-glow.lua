return {
    "y3owk1n/undo-glow.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        animation = {
            enabled = true,
            duration = 250,
            animation_type = "fade",
            fps = 120,
        },
    },
    keys = {
        {
            "u",
            function()
                require("undo-glow").undo()
            end,
            mode = "n",
            desc = "Undo with glow",
        },
        {
            "<C-r>",
            function()
                require("undo-glow").redo()
            end,
            mode = "n",
            desc = "Redo with glow",
        },
        {
            "p",
            function()
                require("undo-glow").paste_below()
            end,
            mode = "n",
            desc = "Paste below with glow",
        },
        {
            "P",
            function()
                require("undo-glow").paste_above()
            end,
            mode = "n",
            desc = "Paste above with glow",
        },
    },
    init = function()
        vim.api.nvim_create_autocmd("TextYankPost", {
            desc = "Highlight when yanking text",
            callback = function()
                require("undo-glow").yank()
            end,
        })
    end,
}
