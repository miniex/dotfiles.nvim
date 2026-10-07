-- A-hjkl: shuffle line/block, reindent on h/l.
return {
    "nvim-mini/mini.move",
    keys = {
        { "<A-h>", mode = { "n", "x" } },
        { "<A-j>", mode = { "n", "x" } },
        { "<A-k>", mode = { "n", "x" } },
        { "<A-l>", mode = { "n", "x" } },
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
