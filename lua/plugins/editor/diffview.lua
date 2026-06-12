-- Multi-file diff UI for branches/merges/history. Complements gitsigns + fugitive.
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
        {
            "<leader>gvf",
            "<cmd>DiffviewFileHistory % --follow<cr>",
            desc = "File History (current file, follows renames)",
        },
        { "<leader>gvF", "<cmd>DiffviewFileHistory<cr>", desc = "File History (repo)" },
        {
            "<leader>gvm",
            function()
                -- Diff the whole branch against the default branch.
                local ref = vim.fn.systemlist("git symbolic-ref --quiet --short refs/remotes/origin/HEAD")[1]
                ref = (ref and ref:gsub("%s+", "")) or ""
                if ref == "" then
                    -- origin/HEAD unset: fall back to whichever of main/master exists.
                    local main = vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", "origin/main" })
                    ref = main ~= "" and "origin/main" or "origin/master"
                end
                vim.cmd("DiffviewOpen " .. ref .. "...HEAD")
            end,
            desc = "Diffview vs default branch",
        },
        { "<leader>gvr", "<cmd>DiffviewRefresh<cr>", desc = "Diffview Refresh" },
        { "<leader>gvh", "<cmd>DiffviewFileHistory % -g --range=stash<cr>", desc = "File History (stash)" },
        { "<leader>gvt", "<cmd>DiffviewToggleFiles<cr>", desc = "Diffview Toggle Files Panel" },
        { "<leader>gvp", "<cmd>DiffviewFocusFiles<cr>", desc = "Diffview Focus Files Panel" },
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
