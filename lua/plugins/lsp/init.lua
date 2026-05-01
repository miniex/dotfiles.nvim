return {
    {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        cmd = { "LspInstall", "LspUninstall" },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
        opts = {
            ensure_installed = {},
            auto_update = false,
            run_on_start = true,
            start_delay = 3000,
            debounce_hours = 24,
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            inlay_hints = { enabled = true },
            servers = {},
        },
        config = function(_, opts)
            vim.lsp.config("*", {
                root_markers = { ".git" },
            })

            local group = vim.api.nvim_create_augroup("lsp-attach-keys", { clear = true })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = group,
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

            -- Disable inlay hints during insert mode to reduce LSP traffic;
            -- restore them on exit if the buffer had them enabled before.
            local hint_group = vim.api.nvim_create_augroup("lsp-inlay-hint-insert", { clear = true })
            vim.api.nvim_create_autocmd("InsertEnter", {
                group = hint_group,
                callback = function(args)
                    if vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }) then
                        vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
                        vim.b[args.buf]._inlay_hint_was_on = true
                    end
                end,
            })
            vim.api.nvim_create_autocmd("InsertLeave", {
                group = hint_group,
                callback = function(args)
                    if vim.b[args.buf]._inlay_hint_was_on then
                        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
                        vim.b[args.buf]._inlay_hint_was_on = nil
                    end
                end,
            })

            local to_install = {}
            for server, server_opts in pairs(opts.servers) do
                if server_opts then
                    if server_opts == true then
                        vim.lsp.enable(server)
                        to_install[#to_install + 1] = server
                    elseif server_opts.enabled ~= false then
                        vim.lsp.config(server, server_opts)
                        vim.lsp.enable(server)
                        to_install[#to_install + 1] = server
                    end
                end
            end

            -- Buffers loaded before this config function ran (e.g., when
            -- nvim opens with multiple file args) may have already passed
            -- their FileType event. Re-fire so the LSP client attaches.
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

            -- Defer mason install setup until after UI is ready. We do not
            -- rely on mason-lspconfig's automatic_enable because we've
            -- already enabled servers natively above.
            vim.api.nvim_create_autocmd("VimEnter", {
                once = true,
                callback = function()
                    vim.schedule(function()
                        require("mason-lspconfig").setup({
                            ensure_installed = to_install,
                            automatic_enable = false,
                        })
                    end)
                end,
            })
        end,
    },
}
