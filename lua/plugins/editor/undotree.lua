-- Persistent undo history tree. Requires undofile (set in options.lua).
return {
    "jiaoshijie/undotree",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        {
            "<leader>uU",
            function()
                require("undotree").toggle()
            end,
            desc = "Toggle Undotree",
        },
    },
    opts = {
        float_diff = true,
        layout = "left_bottom",
        position = "left",
        ignore_filetype = {
            "undotree",
            "undotreeDiff",
            "qf",
            "TelescopePrompt",
            "spectre_panel",
            "tsplayground",
            "neo-tree",
            "snacks_dashboard",
        },
        window = {
            winblend = 0,
        },
        keymaps = {
            ["j"] = "move_next",
            ["k"] = "move_prev",
            ["gj"] = "move2parent",
            ["J"] = "move_change_next",
            ["K"] = "move_change_prev",
            ["<cr>"] = "action_enter",
            ["p"] = "enter_diffbuf",
            ["q"] = "quit",
        },
    },
}
