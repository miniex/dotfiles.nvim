-- Bracket-pair coloring (treesitter). 6-color cycle: damin accents + mocha tones.
return {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        local p = require("config.palette")
        local groups = {
            "RainbowDelimiterBlue",
            "RainbowDelimiterPink",
            "RainbowDelimiterLavender",
            "RainbowDelimiterMauve",
            "RainbowDelimiterTeal",
            "RainbowDelimiterMid",
        }
        local function set_hl()
            local m = p.mocha()
            local fg = {
                RainbowDelimiterBlue = p.blue,
                RainbowDelimiterPink = p.pink,
                RainbowDelimiterLavender = m.lavender,
                RainbowDelimiterMauve = m.mauve,
                RainbowDelimiterTeal = m.teal,
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
        require("rainbow-delimiters.setup").setup({ highlight = groups })
    end,
}
