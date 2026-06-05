-- Toggle a treesitter node between single-line and multi-line form (split/join).
return {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
        {
            "<leader>cJ",
            function()
                require("treesj").toggle()
            end,
            desc = "Split/Join node (treesj)",
        },
    },
    opts = { use_default_keymaps = false },
}
