-- Sidebar/panel layout: aerial=right, trouble/dap=bottom.
-- neo-tree excluded (floating popup).
return {
    "folke/edgy.nvim",
    event = "VeryLazy",
    init = function()
        -- splitkeep=screen prevents cursor jumps on panel open.
        vim.opt.laststatus = 3
        vim.opt.splitkeep = "screen"
    end,
    opts = {
        bottom = {
            {
                ft = "Trouble",
                size = { height = 0.3 },
            },
            { ft = "trouble", size = { height = 0.3 } },
            { ft = "qf", title = "Quickfix" },
            {
                ft = "help",
                size = { height = 20 },
                filter = function(buf)
                    return vim.bo[buf].buftype == "help"
                end,
            },
            { ft = "spectre_panel", size = { height = 0.4 } },
            { ft = "dap-repl", size = { height = 0.25 }, title = "DAP REPL" },
            { ft = "dapui_console", title = "DAP Console" },
        },
        right = {
            { ft = "aerial", title = "Outline", size = { width = 30 } },
            { ft = "dapui_scopes", title = "Scopes" },
            { ft = "dapui_breakpoints", title = "Breakpoints" },
            { ft = "dapui_stacks", title = "Stacks" },
            { ft = "dapui_watches", title = "Watches" },
        },
        animate = {
            enabled = false,
        },
        wo = {
            winbar = true,
            winfixwidth = true,
            winfixheight = false,
            winhighlight = "WinBar:EdgyWinBar,Normal:EdgyNormal",
            spell = false,
            signcolumn = "no",
        },
        keys = {
            -- Resize the focused edge window
            ["<c-Right>"] = function(win)
                win:resize("width", 2)
            end,
            ["<c-Left>"] = function(win)
                win:resize("width", -2)
            end,
            ["<c-Up>"] = function(win)
                win:resize("height", 2)
            end,
            ["<c-Down>"] = function(win)
                win:resize("height", -2)
            end,
        },
    },
}
