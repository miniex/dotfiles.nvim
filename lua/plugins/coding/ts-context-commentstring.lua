return {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    init = function()
        -- Skip the legacy nvim-treesitter module path; we drive it via the
        -- pre_hook on Comment.nvim instead.
        vim.g.skip_ts_context_commentstring_module = true
    end,
    opts = {
        enable_autocmd = false,
    },
    config = function(_, opts)
        require("ts_context_commentstring").setup(opts)
    end,
}
