-- Sublime-style multi-cursors. Triggers under <leader>M + Ctrl-Up/Down.
-- <leader>m is the harpoon group; <C-n>/<C-p> stay with blink.cmp.
return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    keys = function()
        local mc = require("multicursor-nvim")
        return {
            -- Add cursor + jump to next/prev match of <cword>.
            {
                "<leader>Mn",
                function()
                    mc.matchAddCursor(1)
                end,
                mode = { "n", "x" },
                desc = "MC: add cursor + next match",
            },
            {
                "<leader>MN",
                function()
                    mc.matchAddCursor(-1)
                end,
                mode = { "n", "x" },
                desc = "MC: add cursor + prev match",
            },
            -- Skip current match without adding a cursor.
            {
                "<leader>Ms",
                function()
                    mc.matchSkipCursor(1)
                end,
                mode = { "n", "x" },
                desc = "MC: skip match (forward)",
            },
            {
                "<leader>MS",
                function()
                    mc.matchSkipCursor(-1)
                end,
                mode = { "n", "x" },
                desc = "MC: skip match (backward)",
            },
            -- Cursor on every match in buffer.
            {
                "<leader>MA",
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
                "<leader>Mu",
                function()
                    mc.restoreCursors()
                end,
                desc = "MC: restore cursors",
            },
            -- Align cursors with spaces.
            {
                "<leader>Ma",
                function()
                    mc.alignCursors()
                end,
                mode = { "n", "x" },
                desc = "MC: align cursors",
            },
            -- Split visual selection by regex → one cursor per match.
            {
                "<leader>M/",
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
            -- Focus prev/next cursor (only when extra cursors exist; otherwise fall through).
            {
                "<left>",
                function()
                    if mc.hasCursors() then
                        mc.prevCursor()
                    else
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), "n", false)
                    end
                end,
                mode = { "n", "x" },
                desc = "MC: focus prev cursor (or move left)",
            },
            {
                "<right>",
                function()
                    if mc.hasCursors() then
                        mc.nextCursor()
                    else
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), "n", false)
                    end
                end,
                mode = { "n", "x" },
                desc = "MC: focus next cursor (or move right)",
            },
            -- Delete focused cursor.
            {
                "<leader>Mx",
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

        -- Esc: 1st clears cursors; otherwise exit visual / nohlsearch in normal.
        vim.keymap.set({ "n", "x" }, "<esc>", function()
            if not mc.cursorsEnabled() then
                mc.enableCursors()
                return
            end
            if mc.hasCursors() then
                mc.clearCursors()
                return
            end
            local m = vim.fn.mode()
            if m:match("^[vV\22sS\19]") then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, false, true), "n", false)
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
