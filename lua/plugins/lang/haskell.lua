-- haskell-tools.nvim owns HLS (lang_servers.haskell = {}; never set up `hls`).
-- DAP (haskell-debug-adapter) is auto-discovered when nvim-dap is present.
return {
    require("config.lang").mason({ "haskell-language-server" }),
    {
        "mrcjkb/haskell-tools.nvim",
        ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
        keys = {
            {
                "<leader>cE",
                function()
                    require("haskell-tools").repl.toggle()
                end,
                desc = "Haskell: GHCi REPL",
                ft = "haskell",
            },
            {
                "<leader>cR",
                function()
                    require("haskell-tools").hoogle.hoogle_signature()
                end,
                desc = "Haskell: Hoogle signature",
                ft = "haskell",
            },
        },
    },
}
