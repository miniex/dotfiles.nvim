-- Atomic toggle state for <leader>cl; avoids RMW on the global config.
local virt_lines_on = false

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
        -- Native signs/float live in lsp/init.lua; tiny-inline only owns virtual_text.
        config = function(_, opts)
            require("tiny-inline-diagnostic").setup(opts)
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
                    virt_lines_on = not virt_lines_on
                    -- current_line: full diagnostic only on the cursor line (tiny-inline owns the rest).
                    vim.diagnostic.config({ virtual_lines = virt_lines_on and { current_line = true } or false })
                end,
                desc = "Toggle Virtual Lines (current line)",
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
                    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
                end,
                desc = "Next Error",
            },
            {
                "[e",
                function()
                    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
                end,
                desc = "Prev Error",
            },
            {
                "]W",
                function()
                    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN, float = true })
                end,
                desc = "Next Warning",
            },
            {
                "[W",
                function()
                    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN, float = true })
                end,
                desc = "Prev Warning",
            },
        },
    },
}
