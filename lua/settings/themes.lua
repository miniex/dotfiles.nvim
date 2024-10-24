return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        config = function()
            require("rose-pine").setup({
                variant = "moon",
                dark_variant = "moon",
            })

            vim.cmd([[colorscheme rose-pine]])
        end,
    },
    {
        "scottmckendry/cyberdream.nvim",
        name = "cyberdream",
        lazy = false,
        priority = 1000,
        config = function()
            require("cyberdream").setup({
                transparent = true,
                italic_comments = false,
                hide_fillchars = false,
                borderless_telescope = true,
                
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
        end,
    }
}
