local map_key = require("utils.key_mapper").map_key

return {
    {
        "neovim/nvim-lspconfig",
        event = "User FilePost",
        dependencies = {
            "mason.nvim",
            "mason-lspconfig.nvim",
        },
        config = function()
            -- Global mappings
            map_key("K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
            map_key("gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
            map_key("<leader>cc", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
            map_key("<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
            map_key("gr", vim.lsp.buf.references, { desc = "Goto References" })
            map_key("gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
            map_key("<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })

            -- Global handlers
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover, {
                    border = "rounded",
                }
            )

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                vim.lsp.handlers.signature_help, {
                    border = "rounded",
                }
            )

            -- Diagnostic configuration
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = true,
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufWritePre", "BufNewFile" },
        config = function()
            local conform = require("conform")

            conform.setup({
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            })
        end,
        cmd = "ConformInfo"
    }
}
