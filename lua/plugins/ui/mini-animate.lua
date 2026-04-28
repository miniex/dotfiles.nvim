return {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    config = function()
        local animate = require("mini.animate")
        animate.setup({
            -- cursor / scroll handled by smear-cursor.nvim and snacks.scroll
            cursor = { enable = false },
            scroll = { enable = false },
            resize = {
                enable = true,
                timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
            },
            open = {
                enable = true,
                timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
            },
            close = {
                enable = true,
                timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
            },
        })
    end,
}
