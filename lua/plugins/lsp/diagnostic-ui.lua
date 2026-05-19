-- Mutable for the <leader>cM toggle.
local tiny_opts = {
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
}

return {
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "LspAttach",
        opts = tiny_opts,
        config = function(_, opts)
            -- tiny-inline owns rendering; native virtual_text stays off.
            require("tiny-inline-diagnostic").setup(opts)
            vim.diagnostic.config({
                virtual_text = false,
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "✗",
                        [vim.diagnostic.severity.WARN] = "!",
                        [vim.diagnostic.severity.INFO] = "i",
                        [vim.diagnostic.severity.HINT] = "?",
                    },
                },
                float = {
                    border = vim.g.flower_border,
                    source = "if_many",
                    title = " ✿ diagnostics ✿ ",
                    title_pos = "center",
                },
            })
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
            {
                "<leader>cM",
                function()
                    tiny_opts.options.show_all_diags_on_cursorline = not tiny_opts.options.show_all_diags_on_cursorline
                    require("tiny-inline-diagnostic").setup(tiny_opts)
                    vim.notify(
                        "All diagnostics on cursorline: " .. tostring(tiny_opts.options.show_all_diags_on_cursorline)
                    )
                end,
                desc = "Toggle multi-diagnostic on cursorline",
            },
            -- Severity-filtered jumps. ]d/[d still cycles all severities.
            {
                "]e",
                function()
                    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
                end,
                desc = "Next Error",
            },
            {
                "[e",
                function()
                    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
                end,
                desc = "Prev Error",
            },
            {
                "]W",
                function()
                    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN })
                end,
                desc = "Next Warning",
            },
            {
                "[W",
                function()
                    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN })
                end,
                desc = "Prev Warning",
            },
        },
    },
}
