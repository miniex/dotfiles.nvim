-- Sidebar/panel layout: aerial=right, trouble/dap=bottom.
-- neo-tree excluded (floating popup).
return {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
        bottom = {
            { ft = "trouble", size = { height = 0.3 } },
            { ft = "qf", title = "Quickfix" },
            {
                ft = "help",
                size = { height = 20 },
                filter = function(buf)
                    return vim.bo[buf].buftype == "help"
                end,
            },
            { ft = "dap-repl", size = { height = 0.25 }, title = "DAP REPL" },
            { ft = "dapui_console", title = "DAP Console" },
            { ft = "neotest-output-panel", size = { height = 0.25 }, title = "Test Output" },
        },
        right = {
            { ft = "aerial", title = "Outline", size = { width = 30 } },
            { ft = "neotest-summary", title = "Test Summary", size = { width = 40 } },
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
