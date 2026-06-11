-- Motion hints (virtual text). Off by default — it renders on every cursor move, so opt-in.
return {
    "tris203/precognition.nvim",
    keys = {
        {
            "<leader>uP",
            function()
                require("precognition").toggle()
            end,
            desc = "Toggle precognition (motion hints)",
        },
    },
    opts = { startVisible = false },
}
