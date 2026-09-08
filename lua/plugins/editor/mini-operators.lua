-- Operators (mini.operators). Uppercase prefixes: lowercase gr/gs/gx are taken
-- (LSP refs / surround / open-URL). Usage in docs/KEYMAPS.md.
return {
    "nvim-mini/mini.operators",
    event = "VeryLazy",
    opts = {
        replace = { prefix = "gR" },
        exchange = { prefix = "gX" },
        sort = { prefix = "gS" },
        multiply = { prefix = "" }, -- disabled
        evaluate = { prefix = "g=" },
    },
}
