-- Unified [/] motions. Only suffixes whose [x/]x aren't already owned elsewhere
-- are kept: buffer ([b/]b), jump ([j/]j), location ([l/]l), undo ([u/]u).
-- VeryLazy (not keys) so the u/<C-R> undo-ring remaps are active before edits.
return {
    "nvim-mini/mini.bracketed",
    event = "VeryLazy",
    opts = {
        -- Other 10 suffixes disabled — their [x/]x are already taken: c/x/d/f/i/o/q/t/w/y →
        -- keymaps/ts-ctx+conflict/diag-ui/ts-objs/snacks/aerial/trouble/todo/(free)/yanky.
        comment = { suffix = "" },
        conflict = { suffix = "" },
        diagnostic = { suffix = "" },
        file = { suffix = "" },
        indent = { suffix = "" },
        oldfile = { suffix = "" },
        quickfix = { suffix = "" },
        treesitter = { suffix = "" },
        window = { suffix = "" },
        yank = { suffix = "" },
    },
}
