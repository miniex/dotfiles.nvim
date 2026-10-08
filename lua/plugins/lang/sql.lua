return {
    require("config.lang").treesitter({ "sql" }),
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
    require("config.lang").mason({ "sqlfluff" }),
    require("config.lang").lint({ sql = { "sqlfluff" } }),
    {
        "mfussenegger/nvim-lint",
        optional = true,
        opts = function()
            -- Without a project config sqlfluff exits "No dialect was specified" and
            -- prints nothing; fall back to ansi there.
            local base = require("lint.linters.sqlfluff")
            require("lint").linters.sqlfluff = function()
                local name = vim.api.nvim_buf_get_name(0)
                local dir = vim.fs.dirname(name)
                local configured = vim.fs.find(function(name, path)
                    if name == ".sqlfluff" then
                        return true
                    end
                    if name == "pyproject.toml" or name == "setup.cfg" or name == "tox.ini" then
                        local ok, lines = pcall(vim.fn.readfile, path .. "/" .. name)
                        return ok and table.concat(lines, "\n"):find("sqlfluff.-dialect") ~= nil
                    end
                    return false
                end, { upward = true, path = dir, limit = 1 })[1]
                local args = { "lint", "--format=json" }
                if not configured then
                    args[#args + 1] = "--dialect=ansi"
                end
                -- sqlfluff resolves config from this path, not from cwd.
                if name ~= "" then
                    vim.list_extend(args, { "--stdin-filename", name })
                end
                args[#args + 1] = "-"
                return vim.tbl_extend("force", base, { args = args })
            end
        end,
    },
}
