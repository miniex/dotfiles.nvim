-- Brackets/quotes/tags + next/last search (`cin(`, `dan"`). treesitter-textobjects
-- keeps its exact 2-char maps (af/aa/al/…) — mini.ai's 1-char `a`/`i` only fires
-- for chars it owns. Last variant remapped off al/il (treesitter loop) → aL/iL.
return {
    "echasnovski/mini.ai",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        n_lines = 500,
        mappings = {
            around = "a",
            inside = "i",
            around_next = "an",
            inside_next = "in",
            around_last = "aL",
            inside_last = "iL",
            goto_left = "",
            goto_right = "",
        },
    },
}
