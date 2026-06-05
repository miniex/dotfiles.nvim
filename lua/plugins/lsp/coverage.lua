-- Test-coverage gutter signs + summary (reads lcov / coverage.xml / json).
return {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Coverage", "CoverageToggle", "CoverageSummary", "CoverageLoad", "CoverageClear" },
    keys = {
        { "<leader>nc", "<cmd>Coverage<cr>", desc = "Coverage: load & show" },
        { "<leader>nC", "<cmd>CoverageSummary<cr>", desc = "Coverage: summary" },
    },
    opts = { auto_reload = true },
    config = function(_, opts)
        require("coverage").setup(opts)
    end,
}
