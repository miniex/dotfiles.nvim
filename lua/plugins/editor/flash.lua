-- damin-tinted flash labels: pink on transparent, match in blue.
local function set_flash_hl()
    vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#1e1e2e", bg = "#E890B0", bold = true })
    vim.api.nvim_set_hl(0, "FlashMatch", { fg = "#98ABCC", bold = true })
    vim.api.nvim_set_hl(0, "FlashCurrent", { fg = "#E890B0", bold = true, underline = true })
    vim.api.nvim_set_hl(0, "FlashPrompt", { fg = "#E890B0", bg = "NONE" })
    vim.api.nvim_set_hl(0, "FlashPromptIcon", { fg = "#98ABCC", bg = "NONE" })
end
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("FlashDaminPalette", { clear = true }),
    callback = set_flash_hl,
})
set_flash_hl()

return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        {
            "s",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "Flash",
        },
        {
            "S",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "Flash Treesitter",
        },
        {
            "r",
            mode = "o",
            function()
                require("flash").remote()
            end,
            desc = "Remote Flash",
        },
        {
            "R",
            mode = { "o", "x" },
            function()
                require("flash").treesitter_search()
            end,
            desc = "Treesitter Search",
        },
        {
            "<c-s>",
            mode = "c",
            function()
                require("flash").toggle()
            end,
            desc = "Toggle Flash Search",
        },
    },
}
