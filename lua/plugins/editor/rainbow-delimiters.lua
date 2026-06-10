-- Bracket-pair coloring (treesitter). 6 distinct depths: damin accents + mocha
-- tones (peach/green, since the theme collapses mauve/teal onto pink/blue).
return {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        local p = require("config.palette")
        local groups = {
            "RainbowDelimiterBlue",
            "RainbowDelimiterPink",
            "RainbowDelimiterLavender",
            "RainbowDelimiterPeach",
            "RainbowDelimiterGreen",
            "RainbowDelimiterMid",
        }
        local function set_hl()
            local m = p.mocha()
            local fg = {
                RainbowDelimiterBlue = p.blue,
                RainbowDelimiterPink = p.pink,
                RainbowDelimiterLavender = m.lavender,
                RainbowDelimiterPeach = m.peach,
                RainbowDelimiterGreen = m.green,
                RainbowDelimiterMid = p.mid,
            }
            for name, color in pairs(fg) do
                vim.api.nvim_set_hl(0, name, { fg = color })
            end
        end
        set_hl()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("RainbowDelimiterDamin", { clear = true }),
            callback = set_hl,
        })
        require("rainbow-delimiters.setup").setup({
            -- Disable on huge files; the initial full delimiter query is the costly part.
            strategy = {
                [""] = function(bufnr)
                    if vim.api.nvim_buf_line_count(bufnr) > 10000 then
                        return nil
                    end
                    return "rainbow-delimiters.strategy.global"
                end,
            },
            highlight = groups,
        })
    end,
}
