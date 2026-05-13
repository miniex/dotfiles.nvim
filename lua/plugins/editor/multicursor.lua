-- Sublime-style multi-cursors. Triggers under <leader>m + Ctrl-Up/Down.
-- <C-n>/<C-p> kept for blink.cmp.
return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    keys = function()
        local mc = require("multicursor-nvim")
        return {
            -- Add cursor + jump to next/prev match of <cword>.
            {
                "<leader>mn",
                function()
                    mc.matchAddCursor(1)
                end,
                mode = { "n", "x" },
                desc = "MC: add cursor + next match",
            },
            {
                "<leader>mN",
                function()
                    mc.matchAddCursor(-1)
                end,
                mode = { "n", "x" },
                desc = "MC: add cursor + prev match",
            },
            -- Skip current match without adding a cursor.
            {
                "<leader>ms",
                function()
                    mc.matchSkipCursor(1)
                end,
                mode = { "n", "x" },
                desc = "MC: skip match (forward)",
            },
            {
                "<leader>mS",
                function()
                    mc.matchSkipCursor(-1)
                end,
                mode = { "n", "x" },
                desc = "MC: skip match (backward)",
            },
            -- Cursor on every match in buffer.
            {
                "<leader>mA",
                function()
                    mc.matchAllAddCursors()
                end,
                mode = { "n", "x" },
                desc = "MC: cursor on every match",
            },
            -- Add cursor above/below.
            {
                "<C-Up>",
                function()
                    mc.lineAddCursor(-1)
                end,
                mode = { "n", "x" },
                desc = "MC: add cursor above",
            },
            {
                "<C-Down>",
                function()
                    mc.lineAddCursor(1)
                end,
                mode = { "n", "x" },
                desc = "MC: add cursor below",
            },
            -- Restore last cursor set.
            {
                "<leader>mu",
                function()
                    mc.restoreCursors()
                end,
                desc = "MC: restore cursors",
            },
            -- Align cursors with spaces.
            {
                "<leader>ma",
                function()
                    mc.alignCursors()
                end,
                mode = { "n", "x" },
                desc = "MC: align cursors",
            },
            -- Split visual selection by regex → one cursor per match.
            {
                "<leader>m/",
                function()
                    mc.splitCursors()
                end,
                mode = "x",
                desc = "MC: split by regex",
            },
            -- Ctrl-click: add cursor at click.
            {
                "<c-leftmouse>",
                function()
                    mc.handleMouse()
                end,
                desc = "MC: add cursor at mouse",
            },
            -- Focus prev/next cursor.
            {
                "<left>",
                function()
                    mc.prevCursor()
                end,
                mode = { "n", "x" },
                desc = "MC: focus prev cursor",
            },
            {
                "<right>",
                function()
                    mc.nextCursor()
                end,
                mode = { "n", "x" },
                desc = "MC: focus next cursor",
            },
            -- Delete focused cursor.
            {
                "<leader>mx",
                function()
                    mc.deleteCursor()
                end,
                mode = { "n", "x" },
                desc = "MC: delete focused cursor",
            },
        }
    end,
    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()

        -- Esc: 1st clears cursors, 2nd does nohlsearch.
        vim.keymap.set({ "n", "x" }, "<esc>", function()
            if not mc.cursorsEnabled() then
                mc.enableCursors()
            elseif mc.hasCursors() then
                mc.clearCursors()
            else
                vim.cmd("nohlsearch")
            end
        end, { desc = "MC-aware Escape" })

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
