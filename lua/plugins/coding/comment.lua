return {
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gc", mode = { "n", "x" }, desc = "Comment toggle" },
            { "gb", mode = { "n", "x" }, desc = "Comment toggle (block)" },
        },
        dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
        opts = function()
            return {
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            }
        end,
    },
}
