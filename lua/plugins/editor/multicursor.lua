-- Sublime-style multi-cursors. Triggers under <leader>M + Ctrl-Up/Down.
-- <leader>m is the harpoon group; <C-n>/<C-p> stay with blink.cmp.
-- keys stays static (require deferred into callbacks) so it loads on first use, not startup.
return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    keys = {
        -- Add cursor + jump to next/prev match of <cword>.
        {
            "<leader>Mn",
            function()
                require("multicursor-nvim").matchAddCursor(1)
            end,
            mode = { "n", "x" },
            desc = "MC: add cursor + next match",
        },
        {
            "<leader>MN",
            function()
                require("multicursor-nvim").matchAddCursor(-1)
            end,
            mode = { "n", "x" },
            desc = "MC: add cursor + prev match",
        },
        -- Skip current match without adding a cursor.
        {
            "<leader>Ms",
            function()
                require("multicursor-nvim").matchSkipCursor(1)
            end,
            mode = { "n", "x" },
            desc = "MC: skip match (forward)",
        },
        {
            "<leader>MS",
            function()
                require("multicursor-nvim").matchSkipCursor(-1)
            end,
            mode = { "n", "x" },
            desc = "MC: skip match (backward)",
        },
        {
            "<leader>MA",
            function()
                require("multicursor-nvim").matchAllAddCursors()
            end,
            mode = { "n", "x" },
            desc = "MC: cursor on every match",
        },
        -- Add cursor above/below. Edgy uses same chord but scoped to edge windows.
        {
            "<C-Up>",
            function()
                require("multicursor-nvim").lineAddCursor(-1)
            end,
            mode = { "n", "x" },
            desc = "MC: add cursor above",
        },
        {
            "<C-Down>",
            function()
                require("multicursor-nvim").lineAddCursor(1)
            end,
            mode = { "n", "x" },
            desc = "MC: add cursor below",
        },
        {
            "<leader>Mu",
            function()
                require("multicursor-nvim").restoreCursors()
            end,
            desc = "MC: restore cursors",
        },
        -- Align cursors with spaces.
        {
            "<leader>Ma",
            function()
                require("multicursor-nvim").alignCursors()
            end,
            mode = { "n", "x" },
            desc = "MC: align cursors",
        },
        -- Split visual selection by regex → one cursor per match.
        {
            "<leader>M/",
            function()
                require("multicursor-nvim").splitCursors()
            end,
            mode = "x",
            desc = "MC: split by regex",
        },
        {
            "<c-leftmouse>",
            function()
                require("multicursor-nvim").handleMouse()
            end,
            desc = "MC: add cursor at mouse",
        },
        {
            "<leader>Mx",
            function()
                require("multicursor-nvim").deleteCursor()
            end,
            mode = { "n", "x" },
            desc = "MC: delete focused cursor",
        },
        {
            "<leader>Mm",
            function()
                require("multicursor-nvim").toggleCursor()
            end,
            mode = { "n", "x" },
            desc = "MC: toggle cursor here",
        },
    },
    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()

        -- Keymap layer: binds only while cursors exist, restored when they clear.
        -- (Basic i/a/c/d already apply to every cursor — no mapping needed.)
        mc.addKeymapLayer(function(layer)
            layer({ "n", "x" }, "<left>", mc.prevCursor)
            layer({ "n", "x" }, "<right>", mc.nextCursor)
            -- Esc: re-enable disabled cursors, else clear; no cursors falls
            -- through to the global <Esc> (nohlsearch / visual-exit).
            layer({ "n", "x" }, "<esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                else
                    mc.clearCursors()
                end
            end)
        end)

        -- Theme: link to existing groups (catppuccin-mocha).
        vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
        vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
        vim.api.nvim_set_hl(0, "MultiCursorSign", { link = "SignColumn" })
        vim.api.nvim_set_hl(0, "MultiCursorMatchPreview", { link = "Search" })
        vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
        vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        vim.api.nvim_set_hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
}
