local map_key = require("utils.key_mapper").map_key

return {
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                direction = "float",
                float_opts = {
                    border = "double",
                },
                on_open = function(term)
                    local opts = { buffer = term.bufnr }
                    vim.keymap.set("n", "<Esc>", ":ToggleTerm<CR>", opts)
                    vim.keymap.set("n", "q", ":ToggleTerm<CR>", opts)
                    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:ToggleTerm<CR>", opts)
                end,
            })

            map_key("<leader>t", ":ToggleTerm<CR>")
        end,
    },
}
