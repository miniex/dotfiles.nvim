-- Language-agnostic extract / inline refactors (refactoring.nvim); picker on <leader>cr.
return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = { "lewis6991/async.nvim", "nvim-treesitter/nvim-treesitter" },
    keys = {
        {
            "<leader>cr",
            function()
                require("refactoring").select_refactor()
            end,
            mode = { "n", "x" },
            desc = "Refactor (extract / inline)",
        },
    },
    opts = {},
}
