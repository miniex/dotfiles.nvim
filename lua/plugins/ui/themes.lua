return {
    {
        "scottmckendry/cyberdream.nvim",
        name = "cyberdream",
        lazy = false,
        priority = 1000,
        config = function()
            require("cyberdream").setup({
                -- Compile highlights to ~/.cache/nvim/cyberdream_cache.json so
                -- subsequent starts skip theme.setup(). Cyberdream auto-rebuilds
                -- the cache when this file changes.
                cache = true,
                transparent = true,
                italic_comments = false,
                hide_fillchars = false,
                theme = {
                    colors = {
                        bg = "#111213",
                        bgAlt = "#1a1c1e",
                        bgHighlight = "#32363c",
                        fg = "#dddddd",

                        grey = "#8c8c8c",
                        blue = "#82a7e3",
                        green = "#84e082",
                        cyan = "#82e3e3",
                        red = "#e38482",
                        yellow = "#e3e382",
                        magenta = "#e382e3",
                        pink = "#ffb6c1",
                        orange = "#ffcc99",
                        purple = "#b784e3",
                    },
                },
            })

            vim.cmd([[colorscheme cyberdream]])

            local function set_separator()
                vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#ffb6c1", bg = "NONE" })
            end
            set_separator()
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = set_separator,
            })
        end,
    },
}
