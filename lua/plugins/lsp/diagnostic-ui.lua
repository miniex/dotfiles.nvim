return {
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "LspAttach",
        priority = 1000,
        opts = {
            preset = "modern",
            transparent_bg = true,
            options = {
                show_source = { enabled = true, if_many = true },
                use_icons_from_diagnostic = true,
                multilines = {
                    enabled = true,
                    always_show = false,
                },
                show_all_diags_on_cursorline = false,
                enable_on_insert = false,
                overflow = { mode = "wrap" },
                break_line = { enabled = true, after = 100 },
                virt_texts = { priority = 2048 },
            },
            signs = {
                left = "",
                right = "",
                diag = "●",
                arrow = "    ",
                up_arrow = "    ",
                vertical = " │",
                vertical_end = " └",
            },
            blend = {
                factor = 0.22,
            },
        },
        config = function(_, opts)
            -- tiny-inline owns rendering; native virtual_text stays off.
            require("tiny-inline-diagnostic").setup(opts)
            vim.diagnostic.config({ virtual_text = false })
        end,
        keys = {
            {
                "<leader>cd",
                function()
                    require("tiny-inline-diagnostic").toggle()
                end,
                desc = "Toggle Inline Diagnostic",
            },
            {
                "<leader>cl",
                function()
                    local cfg = vim.diagnostic.config() or {}
                    local enabled = cfg.virtual_lines and true or false
                    vim.diagnostic.config({ virtual_lines = not enabled })
                end,
                desc = "Toggle Virtual Lines (multi-line diagnostics)",
            },
        },
    },
}
