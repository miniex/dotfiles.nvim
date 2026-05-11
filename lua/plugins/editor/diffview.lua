-- Diffview: side-by-side diff + file history viewer.
-- Complements gitsigns (hunk-level) and fugitive (porcelain) by adding a
-- proper multi-file diff UI for reviewing branches, merge conflicts, and
-- per-file history.
return {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
        "DiffviewOpen",
        "DiffviewClose",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewRefresh",
        "DiffviewFileHistory",
    },
    keys = {
        { "<leader>gvo", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
        { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
        { "<leader>gvf", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current file)" },
        { "<leader>gvF", "<cmd>DiffviewFileHistory<cr>", desc = "File History (repo)" },
        { "<leader>gvr", "<cmd>DiffviewRefresh<cr>", desc = "Diffview Refresh" },
        { "<leader>gvh", "<cmd>DiffviewFileHistory % --range=stash<cr>", desc = "File History (stash)" },
    },
    opts = {
        enhanced_diff_hl = true,
        view = {
            merge_tool = {
                layout = "diff3_mixed",
                disable_diagnostics = true,
            },
        },
        file_panel = {
            listing_style = "tree",
            win_config = { width = 35 },
        },
        hooks = {
            diff_buf_read = function(_)
                vim.opt_local.wrap = false
                vim.opt_local.list = false
                vim.opt_local.colorcolumn = ""
            end,
        },
    },
}
