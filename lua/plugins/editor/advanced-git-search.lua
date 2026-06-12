-- Search git history by content (log -S/-G/-L, diff vs any past commit). fzf-lua backed.
return {
    "aaronhallaert/advanced-git-search.nvim",
    cmd = "AdvancedGitSearch",
    dependencies = { "ibhagwan/fzf-lua", "tpope/vim-fugitive" },
    keys = {
        { "<leader>gH", "<cmd>AdvancedGitSearch<cr>", desc = "Git: search history" },
    },
    config = function()
        -- Route diffs through diffview (the rest of the git stack standardizes on it).
        require("advanced_git_search.fzf").setup({ diff_plugin = "diffview" })
    end,
}
