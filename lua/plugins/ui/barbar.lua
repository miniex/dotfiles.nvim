local map_key = require("utils.key_mapper").map_key

return {
    "romgrk/barbar.nvim",
    dependencies = {
        "lewis6991/gitsigns.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        vim.g.barbar_auto_setup = false


        map_key("<leader>j", ":BufferPrevious<CR>")
        map_key("<leader>k", ":BufferNext<CR>")
        map_key("<leader>x", ":BufferClose<CR>")
    end,
    opts = {
    },
}
