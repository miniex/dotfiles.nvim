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
    {
        "saghen/blink.cmp",
        optional = true,
        opts = {
            sources = {
                -- Only per_filetype/providers; setting `default` here clobbers the global.
                per_filetype = {
                    sql = { "lsp", "dadbod", "snippets", "buffer" },
                    mysql = { "lsp", "dadbod", "snippets", "buffer" },
                    plsql = { "lsp", "dadbod", "snippets", "buffer" },
                },
                providers = {
                    dadbod = {
                        name = "Dadbod",
                        module = "vim_dadbod_completion.blink",
                    },
                },
            },
        },
    },
}
