return {
    "mawkler/modicator.nvim",
    event = "VeryLazy",
    init = function()
        -- modicator highlights only the line-number column, not the whole line.
        -- The remaining requirements (cursorline, number, termguicolors) are
        -- already set in lua/config/options.lua.
        vim.o.cursorlineopt = "number"
    end,
    opts = {
        show_warnings = false,
        highlights = {
            defaults = { bold = true },
        },
        integration = {
            lualine = { enabled = true },
        },
    },
}
