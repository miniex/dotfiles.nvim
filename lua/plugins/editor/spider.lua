-- camelCase / snake_case-aware w/e/b/ge (matches the `spelloptions=camel` setting).
-- `<cmd>`-string form (not a Lua function) so dot-repeat works for operator motions.
return {
    "chrisgrieser/nvim-spider",
    main = "spider",
    opts = { skipInsignificantPunctuation = true },
    keys = {
        { "w", "<cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" }, desc = "Spider w" },
        { "e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" }, desc = "Spider e" },
        { "b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" }, desc = "Spider b" },
        { "ge", "<cmd>lua require('spider').motion('ge')<CR>", mode = { "n", "o", "x" }, desc = "Spider ge" },
    },
}
