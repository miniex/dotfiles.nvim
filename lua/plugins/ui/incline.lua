-- Per-window floating filename (top-right). Fills the gap for
-- non-focused splits since lualine uses laststatus=3 (global).
return {
    "b0o/incline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    event = "VeryLazy",
    config = function()
        local p = require("catppuccin.palettes").get_palette("mocha")
        local damin_pink = "#E890B0"

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
                    "undotree",
                    "undotreeDiff",
                    "qf",
                },
                unlisted_buffers = false,
                wintypes = "special",
            },
            render = function(props)
                local bufname = vim.api.nvim_buf_get_name(props.buf)
                local filename = bufname == "" and "[No Name]" or vim.fn.fnamemodify(bufname, ":t")
                local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
                local modified = vim.bo[props.buf].modified
                local readonly = vim.bo[props.buf].readonly
                -- ⌬ = "zoom": this window owns its tabpage alone.
                local zoomed = #vim.api.nvim_tabpage_list_wins(0) == 1

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
