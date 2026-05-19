-- Per-window floating filename (top-right). Fills the gap for
-- non-focused splits since lualine uses laststatus=3 (global).
return {
    "b0o/incline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
    event = "VeryLazy",
    config = function()
        local p = require("catppuccin.palettes").get_palette("mocha")
        local damin_pink = "#E890B0"
        local devicons = require("nvim-web-devicons")
        local icon_cache = {}
        local function icon_for(filename)
            local hit = icon_cache[filename]
            if hit then
                return hit[1], hit[2]
            end
            local i, c = devicons.get_icon_color(filename)
            icon_cache[filename] = { i, c }
            return i, c
        end
        -- Devicon colors can change with the theme.
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("InclineIconCache", { clear = true }),
            callback = function()
                icon_cache = {}
            end,
        })

        require("incline").setup({
            window = {
                padding = 0,
                margin = { horizontal = 0, vertical = 0 },
                placement = { horizontal = "right", vertical = "top" },
                zindex = 30,
            },
            hide = {
                cursorline = false,
                focused_win = false,
                only_win = "count_ignored",
            },
            -- Skip chrome buffers (they have their own labels).
            ignore = {
                buftypes = function(_, buftype)
                    return buftype ~= "" and buftype ~= "acwrite"
                end,
                filetypes = {
                    "snacks_dashboard",
                    "neo-tree",
                    "Trouble",
                    "trouble",
                    "aerial",
                    "dap-repl",
                    "dapui_scopes",
                    "dapui_breakpoints",
                    "dapui_stacks",
                    "dapui_watches",
                    "dapui_console",
                    "lazy",
                    "mason",
                    "nvim-undotree",
                    "qf",
                },
                unlisted_buffers = false,
                wintypes = "special",
            },
            render = function(props)
                if not vim.api.nvim_buf_is_valid(props.buf) then
                    return ""
                end
                local bufname = vim.api.nvim_buf_get_name(props.buf)
                local filename = bufname == "" and "[No Name]" or vim.fn.fnamemodify(bufname, ":t")
                local ft_icon, ft_color = icon_for(filename)
                local modified = vim.bo[props.buf].modified
                local readonly = vim.bo[props.buf].readonly
                -- ⌬ = "zoom": this window owns its tabpage alone.
                local tab = props.tab or vim.api.nvim_win_get_tabpage(props.win)
                local zoomed = #vim.api.nvim_tabpage_list_wins(tab) == 1

                local accent = props.focused and damin_pink or p.overlay1

                return {
                    zoomed and { "⌬ ", guifg = damin_pink } or "",
                    ft_icon and { ft_icon, " ", guifg = ft_color } or "",
                    {
                        filename,
                        gui = props.focused and "bold" or "NONE",
                        guifg = accent,
                    },
                    modified and { " ✿", guifg = damin_pink } or "",
                    readonly and { " ✗", guifg = p.red } or "",
                    guibg = "NONE",
                }
            end,
        })
    end,
}
