return {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    config = function()
        local animate = require("mini.animate")
        animate.setup({
            -- cursor / scroll handled by smear-cursor.nvim and snacks.scroll
            cursor = { enable = false },
            scroll = { enable = false },
            resize = { enable = false },
            open = { enable = false },
            close = { enable = false },
        })
    end,
}
