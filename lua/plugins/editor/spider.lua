-- camelCase / snake_case-aware w/e/b/ge (matches the `spelloptions=camel` setting).
return {
    "chrisgrieser/nvim-spider",
    main = "spider",
    opts = { skipInsignificantPunctuation = true },
    keys = {
        {
            "w",
            function()
                require("spider").motion("w")
            end,
            mode = { "n", "o", "x" },
            desc = "Spider w",
        },
        {
            "e",
            function()
                require("spider").motion("e")
            end,
            mode = { "n", "o", "x" },
            desc = "Spider e",
        },
        {
            "b",
            function()
                require("spider").motion("b")
            end,
            mode = { "n", "o", "x" },
            desc = "Spider b",
        },
        {
            "ge",
            function()
                require("spider").motion("ge")
            end,
            mode = { "n", "o", "x" },
            desc = "Spider ge",
        },
    },
}
