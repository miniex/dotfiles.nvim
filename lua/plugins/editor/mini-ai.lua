-- Brackets/quotes/tags. mini.ai's 1-char `a`/`i` only fires for chars it owns
-- (treesitter-textobjects keeps af/aa/al/…). next/last on aN/iN, aL/iL: frees
-- 0.12's native node selection (an/in/]n/[n).
return {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {
        n_lines = 500,
        mappings = {
            around = "a",
            inside = "i",
            around_next = "aN",
            inside_next = "iN",
            around_last = "aL",
            inside_last = "iL",
            goto_left = "",
            goto_right = "",
        },
        -- Extra objects on free chars: g = whole buffer, d = digit run.
        custom_textobjects = {
            g = function()
                return {
                    from = { line = 1, col = 1 },
                    to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) },
                }
            end,
            d = { "%f[%d]%d+" },
        },
    },
}
