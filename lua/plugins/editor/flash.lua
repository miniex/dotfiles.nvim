-- damin-tinted flash labels: pink on transparent, match in blue.
local function set_flash_hl()
    local pal = require("config.palette")
    vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#1e1e2e", bg = pal.pink, bold = true })
    vim.api.nvim_set_hl(0, "FlashMatch", { fg = pal.blue, bold = true })
    vim.api.nvim_set_hl(0, "FlashCurrent", { fg = pal.pink, bold = true, underline = true })
    vim.api.nvim_set_hl(0, "FlashPrompt", { fg = pal.pink, bg = "NONE" })
    vim.api.nvim_set_hl(0, "FlashPromptIcon", { fg = pal.blue, bg = "NONE" })
end

return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    -- Set highlights on load (not at spec-import); re-apply on colorscheme change.
    config = function(_, opts)
        require("flash").setup(opts)
        set_flash_hl()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("FlashDaminPalette", { clear = true }),
            callback = set_flash_hl,
        })
    end,
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
