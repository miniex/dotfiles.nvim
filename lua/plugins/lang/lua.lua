return {
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    -- inherit_defaults extends (not replaces) the global sources.
    require("config.lang").blink({
        lua = { "lazydev", inherit_defaults = true },
    }, {
        lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
        },
    }),
}
