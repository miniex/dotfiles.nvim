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
                    vim.keymap.set("t", "<C-x>", [[<C-\><C-n><cmd>ToggleTerm<CR>]], opts)
                    vim.keymap.set("n", "<C-x>", "<cmd>ToggleTerm<CR>", opts)
                end,
            })

            vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>", { silent = true })
        end,
    },
}
