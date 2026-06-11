return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
        { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
        { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
        { "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>", desc = "LSP References (Trouble)" },
        { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
        { "gO", "<cmd>Trouble lsp toggle<cr>", desc = "LSP Definitions / References (Trouble)" },
        { "<leader>xi", "<cmd>Trouble lsp_incoming_calls toggle<cr>", desc = "Incoming Calls (Trouble)" },
        { "<leader>xo", "<cmd>Trouble lsp_outgoing_calls toggle<cr>", desc = "Outgoing Calls (Trouble)" },
        { "<leader>xy", "<cmd>Trouble lsp_type_definitions toggle<cr>", desc = "Type Definitions (Trouble)" },
        { "<leader>xm", "<cmd>Trouble lsp_implementations toggle<cr>", desc = "Implementations (Trouble)" },
        {
            "[q",
            function()
                if require("trouble").is_open() then
                    require("trouble").prev({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.cmd.cprev)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Previous Trouble/Quickfix Item",
        },
        {
            "]q",
            function()
                if require("trouble").is_open() then
                    require("trouble").next({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.cmd.cnext)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Next Trouble/Quickfix Item",
        },
    },
    opts = {
        auto_close = true,
        preview = { type = "main" },
    },
}
