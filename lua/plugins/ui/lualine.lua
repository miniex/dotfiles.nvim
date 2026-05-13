return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic", "catppuccin/nvim" },
    config = function()
        local p = require("catppuccin.palettes").get_palette("mocha")
        local navic = require("nvim-navic")

        local damin_blue = "#98ABCC"
        local damin_pink = "#E890B0"

        -- damin: text-on-transparent. ✿ glyph color = mode (blue/pink/red/dim).
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

        -- Mode → glyph map. ✎ for visual/operator (echoes tmux copy-mode).
        local mode_glyph = {
            n = "✿",
            i = "✿",
            v = "✎",
            V = "✎",
            ["\22"] = "✎", -- visual-block
            s = "✎",
            S = "✎",
            ["\19"] = "✎", -- select-block
            no = "✎", -- operator-pending
            R = "✿",
            c = "✿",
            t = "✿",
        }

        -- Sparkle pulse on ModeChanged: glyph briefly swaps to ✦.
        local sparkle = { active = false }
        vim.api.nvim_create_autocmd("ModeChanged", {
            group = vim.api.nvim_create_augroup("LualineSparklePulse", { clear = true }),
            callback = function()
                sparkle.active = true
                vim.defer_fn(function()
                    sparkle.active = false
                    pcall(vim.cmd.redrawstatus)
                end, 180)
                pcall(vim.cmd.redrawstatus)
            end,
        })

        local function current_glyph()
            if sparkle.active then
                return "✦"
            end
            return mode_glyph[vim.fn.mode()] or "✿"
        end

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
                    -- ✧ sparkle bookend (tmux statusline echo).
                    {
                        function()
                            return "✧"
                        end,
                        padding = { left = 1, right = 0 },
                        color = { fg = damin_blue },
                    },
                    {
                        "mode",
                        icons_enabled = false,
                        fmt = function(str)
                            return current_glyph() .. " " .. str:lower()
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
                    -- ⋆ sparkle bookend (right).
                    {
                        function()
                            return "⋆"
                        end,
                        padding = { left = 0, right = 1 },
                        color = { fg = damin_pink },
                    },
                },
            },
            extensions = { "lazy", "mason", "neo-tree", "trouble" },
        })
    end,
}
