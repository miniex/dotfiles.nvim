return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic", "catppuccin/nvim" },
    config = function()
        local p = require("catppuccin.palettes").get_palette("mocha")
        local navic = require("nvim-navic")

        local damin_blue = "#98ABCC"
        local damin_pink = "#E890B0"

        -- fish-theme-damin is text-on-transparent: no filled badges, no bright
        -- block backgrounds. Mode is signaled by the accent color of the ✿
        -- glyph alone — blue=normal, pink=insert/visual, red=replace, dim
        -- overlay=command/inactive.
        local damin_theme = {
            normal = {
                a = { fg = damin_blue, bg = "NONE", gui = "bold" },
                b = { fg = damin_blue, bg = "NONE" },
                c = { fg = p.overlay1, bg = "NONE" },
            },
            insert = {
                a = { fg = damin_pink, bg = "NONE", gui = "bold" },
                b = { fg = damin_pink, bg = "NONE" },
                c = { fg = p.overlay1, bg = "NONE" },
            },
            visual = {
                a = { fg = damin_pink, bg = "NONE", gui = "bold" },
                b = { fg = damin_pink, bg = "NONE" },
                c = { fg = p.overlay1, bg = "NONE" },
            },
            replace = {
                a = { fg = p.red, bg = "NONE", gui = "bold" },
                b = { fg = p.red, bg = "NONE" },
                c = { fg = p.overlay1, bg = "NONE" },
            },
            command = {
                a = { fg = p.overlay2, bg = "NONE", gui = "bold" },
                b = { fg = p.overlay2, bg = "NONE" },
                c = { fg = p.overlay1, bg = "NONE" },
            },
            inactive = {
                a = { fg = p.overlay0, bg = "NONE" },
                b = { fg = p.overlay0, bg = "NONE" },
                c = { fg = p.overlay0, bg = "NONE" },
            },
        }

        require("lualine").setup({
            options = {
                theme = damin_theme,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                globalstatus = true,
                disabled_filetypes = { statusline = { "snacks_dashboard" } },
                refresh = { statusline = 1000 },
            },
            sections = {
                lualine_a = {
                    {
                        "mode",
                        icons_enabled = false,
                        fmt = function(str)
                            return "✿ " .. str:lower()
                        end,
                    },
                },
                lualine_b = {
                    { "branch", icon = "", color = { fg = damin_blue } },
                },
                lualine_c = {
                    {
                        "diagnostics",
                        symbols = { error = "✗ ", warn = "! ", info = "i ", hint = "? " },
                    },
                    {
                        "filetype",
                        icon_only = true,
                        separator = "",
                        padding = { left = 1, right = 0 },
                        color = { fg = p.overlay1 },
                    },
                    {
                        "filename",
                        symbols = { modified = " ✿", readonly = " ✗", unnamed = "" },
                        color = { fg = p.overlay2 },
                    },
                    {
                        navic.get_location,
                        cond = navic.is_available,
                        color = { fg = p.overlay0 },
                    },
                },
                lualine_x = {
                    {
                        require("lazy.status").updates,
                        cond = require("lazy.status").has_updates,
                        color = { fg = damin_pink },
                    },
                    {
                        "diff",
                        symbols = { added = "✓", modified = "✗", removed = "−" },
                        diff_color = {
                            added = { fg = damin_blue },
                            modified = { fg = damin_pink },
                            removed = { fg = p.overlay1 },
                        },
                    },
                },
                lualine_y = {
                    { "progress", color = { fg = p.overlay1 } },
                    { "location", color = { fg = p.overlay2 } },
                },
                lualine_z = {
                    {
                        function()
                            return "❥ " .. os.date("%H:%M")
                        end,
                        color = { fg = damin_pink },
                    },
                },
            },
            extensions = { "lazy", "mason", "neo-tree", "trouble" },
        })
    end,
}
