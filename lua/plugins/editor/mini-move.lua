-- A-hjkl: shuffle line/block, reindent on h/l.
return {
    "echasnovski/mini.move",
    keys = {
        { "<A-h>", mode = { "n", "v" } },
        { "<A-j>", mode = { "n", "v" } },
        { "<A-k>", mode = { "n", "v" } },
        { "<A-l>", mode = { "n", "v" } },
    },
    opts = {
        mappings = {
            left = "<A-h>",
            right = "<A-l>",
            down = "<A-j>",
            up = "<A-k>",
            line_left = "<A-h>",
            line_right = "<A-l>",
            line_down = "<A-j>",
            line_up = "<A-k>",
        },
        options = { reindent_linewise = true },
    },
}
