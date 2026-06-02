return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
    config = function()
        local palette = require("config.palette")
        local p = palette.mocha()

        local damin_blue = palette.blue
        local damin_pink = palette.pink

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
        -- Generation counter so rapid mode flips coalesce into one redraw.
        local sparkle = { active = false, gen = 0 }
        vim.api.nvim_create_autocmd("ModeChanged", {
            group = vim.api.nvim_create_augroup("LualineSparklePulse", { clear = true }),
            callback = function()
                sparkle.active = true
                sparkle.gen = sparkle.gen + 1
                local my_gen = sparkle.gen
                vim.defer_fn(function()
                    if sparkle.gen ~= my_gen then
                        return
                    end
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

        -- lualine's default refresh misses these events.
        vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
            group = vim.api.nvim_create_augroup("LualineMacroRedraw", { clear = true }),
            callback = function()
                vim.schedule(vim.cmd.redrawstatus)
            end,
        })

        -- Cache the clock; a minute-aligned timer refreshes it, not every render.
        if _G._lualine_clock_timer then
            pcall(function()
                _G._lualine_clock_timer:stop()
                _G._lualine_clock_timer:close()
            end)
        end
        local clock_str = os.date("%H:%M")
        local clock_timer = (vim.uv or vim.loop).new_timer()
        _G._lualine_clock_timer = clock_timer
        clock_timer:start(
            (60 - tonumber(os.date("%S"))) * 1000,
            60000,
            vim.schedule_wrap(function()
                clock_str = os.date("%H:%M")
                if package.loaded["lualine"] then
                    vim.cmd("redrawstatus")
                end
            end)
        )

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
                    {
                        function()
                            return "● @" .. vim.fn.reg_recording()
                        end,
                        cond = function()
                            return vim.fn.reg_recording() ~= ""
                        end,
                        color = { fg = damin_pink, gui = "bold" },
                    },
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
                },
                lualine_x = {
                    {
                        -- Attached LSP client name(s) for the current buffer.
                        function()
                            local names = {}
                            for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                                names[#names + 1] = client.name
                            end
                            return table.concat(names, ", ")
                        end,
                        cond = function()
                            return next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil
                        end,
                        color = { fg = damin_blue },
                    },
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
                    {
                        -- Search match count, shown only while hlsearch is on.
                        function()
                            local s = vim.fn.searchcount({ maxcount = 999 })
                            if not s.total or s.total == 0 then
                                return ""
                            end
                            return ("⌕ %d/%d"):format(s.current, s.total)
                        end,
                        cond = function()
                            return vim.v.hlsearch == 1
                        end,
                        color = { fg = p.overlay1 },
                    },
                    { "progress", color = { fg = p.overlay1 } },
                    { "location", color = { fg = p.overlay2 } },
                },
                lualine_z = {
                    {
                        function()
                            return "❥ " .. clock_str
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
