-- Search git history by content (log -S/-G/-L, diff vs any past commit). fzf-lua backed.
return {
    "aaronhallaert/advanced-git-search.nvim",
    cmd = "AdvancedGitSearch",
    dependencies = { "ibhagwan/fzf-lua", "tpope/vim-fugitive" },
    keys = {
        { "<leader>gH", "<cmd>AdvancedGitSearch<cr>", desc = "Git: search history" },
    },
    config = function()
        require("advanced_git_search.fzf").setup({})
    end,
}
