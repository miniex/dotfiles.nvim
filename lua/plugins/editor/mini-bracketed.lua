-- Unified [/] motions. Only suffixes whose [x/]x aren't already owned elsewhere
-- are kept: buffer ([b/]b), jump ([j/]j), location ([l/]l), undo ([u/]u).
-- VeryLazy (not keys) so the u/<C-R> undo-ring remaps are active before edits.
return {
    "nvim-mini/mini.bracketed",
    event = "VeryLazy",
    opts = {
        -- Other suffixes disabled: their [x/]x belong to keymaps / ts-context / diagnostics /
        -- ts-textobjects / snacks / aerial / trouble / todo-comments. [w/]w and [y/]y are free.
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
