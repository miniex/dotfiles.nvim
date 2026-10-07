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
    require("config.lang").mason({ "selene" }),
    require("config.lang").lint({ lua = { "selene" } }),
    require("config.lang").neotest("MisanthropicBit/neotest-busted", function()
        return require("neotest-busted")
    end),
    require("config.lang").neotest("nvim-neotest/neotest-plenary", function()
        return require("neotest-plenary")
    end),
    -- Its rockspec adds a non-lazy spec for itself.
    { "MisanthropicBit/neotest-busted", lazy = true },
}
