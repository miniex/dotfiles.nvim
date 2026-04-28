return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local colors = require("cyberdream.colors").default

        require("lualine").setup({
            options = {
                theme = "cyberdream",

                component_separators = { left = " ", right = " " },
                section_separators = { left = " ", right = " " },
                globalstatus = true,
                disabled_filetypes = { statusline = { "dashboard", "alpha" } },
            },
            sections = {
                lualine_a = {
                    {
                        "mode",
                        icons_enabled = true,
                        fmt = function(str)
                            return "  " .. str
                        end,
                    },
                },
                lualine_b = { { "branch", icon = " " } },
                lualine_c = {
                    {
                        "diagnostics",
                        symbols = {
                            error = "  ",
                            warn = "  ",
                            info = "  ",
                            hint = "󰝶  ",
                        },
                    },
                    { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                    {
                        "filename",
                        symbols = { modified = "   ", readonly = "", unnamed = "" },
                    },
                    {
                        function()
                            return require("nvim-navic").get_location()
                        end,
                        cond = function()
                            return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
                        end,
                        color = { fg = colors.grey, bg = colors.none },
                    },
                },
                lualine_x = {
                    {
                        require("lazy.status").updates,
                        cond = require("lazy.status").has_updates,
                        color = { fg = colors.green },
                    },
                    { "diff" },
                },
                lualine_y = {
                    {
                        "progress",
                    },
                    {
                        "location",
                        color = { fg = colors.cyan, bg = colors.none },
                    },
                },
                lualine_z = {
                    function()
                        return "  " .. os.date("%H:%M:%S")
                    end,
                },
            },
            extensions = { "lazy", "toggleterm", "mason", "neo-tree", "trouble" },
        })
    end,
}
