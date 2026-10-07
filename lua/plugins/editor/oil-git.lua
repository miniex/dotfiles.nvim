-- Git status in oil: colored names + a status mark, folders show their highest-priority child.
local pal = require("config.palette")

return {
    "malewicz1337/oil-git.nvim",
    ft = "oil",
    dependencies = { "stevearc/oil.nvim" },
    opts = {
        highlights = {
            OilGitAdded = { fg = pal.git_add },
            OilGitModified = { fg = pal.pink },
            OilGitRenamed = { fg = pal.pink },
            OilGitCopied = { fg = pal.pink },
            OilGitBranch = { fg = pal.blue },
            OilGitDeleted = { fg = pal.git_delete },
            OilGitUntracked = { fg = pal.blue },
            OilGitConflict = { fg = pal.git_delete, bold = true },
            OilGitIgnored = { fg = pal.dim },
        },
    },
}
