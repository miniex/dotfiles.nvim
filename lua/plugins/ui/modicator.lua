return {
    "mawkler/modicator.nvim",
    event = "VeryLazy",
    init = function()
        -- Highlight only line-number column. Other requirements in options.lua.
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
