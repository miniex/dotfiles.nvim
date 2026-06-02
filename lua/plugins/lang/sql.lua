return {
    { "tpope/vim-dadbod", cmd = "DB", lazy = true },
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            "tpope/vim-dadbod",
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        },
        cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
        keys = {
            { "<leader>uD", "<cmd>DBUIToggle<cr>", desc = "Toggle Database UI" },
        },
        init = function()
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_database_icon = 1
        end,
    },
    -- inherit_defaults extends (not replaces) the global sources.
    require("config.lang").blink({
        sql = { "dadbod", inherit_defaults = true },
        mysql = { "dadbod", inherit_defaults = true },
        plsql = { "dadbod", inherit_defaults = true },
    }, {
        dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
        },
    }),
}
