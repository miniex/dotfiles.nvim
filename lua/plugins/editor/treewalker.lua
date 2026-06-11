-- Move/swap the cursor by AST node. <C-hjkl> is smart-splits and <A-hjkl> is mini.move,
-- so movement goes on Alt+arrows, swap on Alt+Shift+arrows.
return {
    "aaronik/treewalker.nvim",
    keys = {
        { "<A-Up>", "<cmd>Treewalker Up<cr>", mode = { "n", "v" }, silent = true, desc = "Treewalker: up (prev node)" },
        {
            "<A-Down>",
            "<cmd>Treewalker Down<cr>",
            mode = { "n", "v" },
            silent = true,
            desc = "Treewalker: down (next node)",
        },
        {
            "<A-Left>",
            "<cmd>Treewalker Left<cr>",
            mode = { "n", "v" },
            silent = true,
            desc = "Treewalker: out (parent)",
        },
        {
            "<A-Right>",
            "<cmd>Treewalker Right<cr>",
            mode = { "n", "v" },
            silent = true,
            desc = "Treewalker: in (child)",
        },
        { "<A-S-Up>", "<cmd>Treewalker SwapUp<cr>", mode = "n", silent = true, desc = "Treewalker: swap up" },
        { "<A-S-Down>", "<cmd>Treewalker SwapDown<cr>", mode = "n", silent = true, desc = "Treewalker: swap down" },
        { "<A-S-Left>", "<cmd>Treewalker SwapLeft<cr>", mode = "n", silent = true, desc = "Treewalker: swap left" },
        { "<A-S-Right>", "<cmd>Treewalker SwapRight<cr>", mode = "n", silent = true, desc = "Treewalker: swap right" },
    },
    opts = {},
}
