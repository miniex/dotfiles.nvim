-- Unified [/] motions. Only suffixes whose [x/]x aren't already owned elsewhere
-- are kept: jump ([j/]j), location ([l/]l), undo ([u/]u).
return {
    "echasnovski/mini.bracketed",
    keys = { "[j", "]j", "[l", "]l", "[u", "]u" },
    opts = {
        -- Other 11 suffixes disabled — their [x/]x are already taken: b/c/x/d/f/i/o/q/t/w/y →
        -- bufferline/keymaps/ts-ctx+conflict/diag-ui/ts-objs/snacks/aerial/trouble/todo/dropbar/yanky.
        buffer = { suffix = "" },
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
