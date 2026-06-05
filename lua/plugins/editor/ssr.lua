-- Structural search & replace: AST-aware, `$x` metavariables (complements grug-far's regex).
return {
    "cshuaimin/ssr.nvim",
    keys = {
        {
            "<leader>rs",
            function()
                require("ssr").open()
            end,
            mode = { "n", "x" },
            desc = "Structural search/replace",
        },
    },
}
