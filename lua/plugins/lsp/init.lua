return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason.nvim",
            "mason-lspconfig.nvim",
        },
        opts = {
            inlay_hints = { enabled = true },
            servers = {},
        },
        config = function(_, opts)
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach-keys", { clear = true }),
                callback = function(args)
                    local bufnr = args.buf
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                    end

                    map("n", "K", function()
                        vim.lsp.buf.hover({ border = "rounded" })
                    end, "Hover")
                    map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
                    map("n", "gr", vim.lsp.buf.references, "References")
                    map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
                    map("n", "<leader>cc", vim.diagnostic.open_float, "Line Diagnostics")
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    map("n", "<leader>ci", function()
                        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
                        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
                    end, "Toggle Inlay Hints")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                    map("i", "<C-k>", function()
                        vim.lsp.buf.signature_help({ border = "rounded" })
                    end, "Signature Help")

                    if opts.inlay_hints.enabled then
                        local client = vim.lsp.get_client_by_id(args.data.client_id)
                        if client and client:supports_method("textDocument/inlayHint") then
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end
                    end
                end,
            })

            local has_blink, blink = pcall(require, "blink.cmp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                has_blink and blink.get_lsp_capabilities({}, false) or {}
            )
            vim.lsp.config("*", { capabilities = capabilities })

            local ensure_installed = {}
            for server, server_opts in pairs(opts.servers) do
                if server_opts then
                    if server_opts == true then
                        ensure_installed[#ensure_installed + 1] = server
                    elseif server_opts.enabled ~= false then
                        vim.lsp.config(server, server_opts)
                        ensure_installed[#ensure_installed + 1] = server
                    end
                end
            end

            require("mason-lspconfig").setup({
                ensure_installed = ensure_installed,
                automatic_enable = { exclude = { "rust_analyzer" } },
            })

            -- automatic_enable's FileType autocmd is registered after files
            -- already triggered FileType during startup. Re-fire for loaded
            -- buffers so LSP attaches to them too.
            vim.schedule(function()
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
                        local ft = vim.bo[buf].filetype
                        if ft and ft ~= "" then
                            vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
                        end
                    end
                end
            end)
        end,
    },
}
