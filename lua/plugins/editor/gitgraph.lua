-- In-buffer git log graph. Pairs with lazygit (TUI) + diffview (file-level).
return {
    "isakbm/gitgraph.nvim",
    dependencies = { "sindrets/diffview.nvim" },
    cmd = { "GitGraph", "GitGraphToggle" },
    keys = {
        {
            "<leader>gvg",
            function()
                require("gitgraph").draw({}, { all = true, max_count = 5000 })
            end,
            desc = "Git Graph (all branches)",
        },
        {
            "<leader>gvG",
            function()
                require("gitgraph").draw({}, { all = false, max_count = 5000 })
            end,
            desc = "Git Graph (current branch)",
        },
    },
    opts = {
        symbols = {
            merge_commit = "M",
            commit = "*",
            merge_commit_end = "M",
            commit_end = "*",
            -- Box-drawing connectors (no nerd-font deps).
            GVER = "│",
            GHOR = "─",
            GCLD = "╮",
            GCRD = "╭",
            GCLU = "╯",
            GCRU = "╰",
            GLRU = "┴",
            GLRD = "┬",
            GLUD = "┤",
            GRUD = "├",
            GFORKU = "┼",
            GFORKD = "┼",
            GRUDCD = "├",
            GRUDCU = "├",
            GLUDCD = "┤",
            GLUDCU = "┤",
            GLRDCL = "┬",
            GLRDCR = "┬",
            GLRUCL = "┴",
            GLRUCR = "┴",
        },
        format = {
            timestamp = "%Y-%m-%d %H:%M",
            fields = { "hash", "timestamp", "author", "branch_name", "tag" },
        },
        hooks = {
            on_select_commit = function(commit)
                vim.notify("Diffview: " .. commit.hash)
                vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
            end,
            on_select_range_commit = function(from, to)
                vim.notify("Diffview range: " .. from.hash .. " → " .. to.hash)
                vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
            end,
        },
    },
}
