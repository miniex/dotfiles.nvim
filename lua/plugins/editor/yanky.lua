-- Yank ring: cycle through earlier yanks after a paste ([y/]y).
return {
    "gbprod/yanky.nvim",
    -- Load early so its TextYankPost hook records the ring from the first yank.
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        ring = { storage = "memory" },
        -- The TextYankPost autocmd in config/autocmds.lua owns the system clipboard.
        system_clipboard = { sync_with_ring = false },
        highlight = { timer = 150 },
    },
    keys = {
        { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after (yanky)" },
        { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before (yanky)" },
        { "]y", "<Plug>(YankyNextEntry)", desc = "Cycle to newer yank" },
        { "[y", "<Plug>(YankyPreviousEntry)", desc = "Cycle to older yank" },
        -- Linewise put, reindented to the current line.
        { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented (after)" },
        { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented (before)" },
        {
            "<leader>yh",
            function()
                require("yanky.picker").select_in_history()
            end,
            desc = "Yank history (pick + put)",
        },
    },
}
