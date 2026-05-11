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
        dependencies = { "williamboman/mason.nvim" },
        cmd = { "LspInstall", "LspUninstall" },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        event = "VeryLazy",
        cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
        -- lazy.nvim's default opts merge replaces arrays rather than concatenating
        -- them, so every spec contributing to ensure_installed (lint, dap, lang)
        -- would clobber the previous one. opts_extend tells lazy to list-append
        -- this specific key across specs.
        opts_extend = { "ensure_installed" },
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

            -- Diagnostic config moved here so the cost is paid only when the
            -- first buffer triggers nvim-lspconfig load (BufReadPre/BufNewFile),
            -- not at startup.
            local diagnostic = vim.diagnostic
            diagnostic.config({
                virtual_text = false,
                signs = {
                    text = {
                        [diagnostic.severity.ERROR] = "󰅚 ",
                        [diagnostic.severity.WARN] = "󰀪 ",
                        [diagnostic.severity.HINT] = "󰌶 ",
                        [diagnostic.severity.INFO] = "󰋽 ",
                    },
                },
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
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
                    map("n", "<leader>cL", vim.lsp.codelens.run, "Run CodeLens")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                    map("i", "<C-k>", function()
                        vim.lsp.buf.signature_help({ border = "rounded" })
                    end, "Signature Help")

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client then
                        if opts.inlay_hints.enabled and client:supports_method("textDocument/inlayHint") then
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end

                        -- CodeLens (test/run/debug actions for rust-analyzer,
                        -- gopls, jdtls, etc.). enable() registers nvim's
                        -- internal autocmds that keep the lenses fresh, so
                        -- no manual refresh loop is needed here.
                        if client:supports_method("textDocument/codeLens") then
                            vim.lsp.codelens.enable(true, { bufnr = bufnr })
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

            -- mason.setup() prepends its bin dir to PATH, but it runs lazily
            -- (only when mason-lspconfig is required). This config function
            -- runs first (BufReadPre/BufNewFile), so vim.fn.executable would
            -- miss tools that mason has already installed but hasn't yet
            -- exposed. Prepend now so cmd_executable below sees them.
            local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
            if not vim.env.PATH:find(mason_bin, 1, true) then
                vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
            end

            -- A server's cmd may be a list, string, or function. List/string
            -- forms expose the binary directly so we can check $PATH. Function
            -- forms (used by many lspconfig defaults like tailwindcss, jsonls,
            -- yamlls) hide the binary inside a closure -- we can't cheaply
            -- inspect them, so treat as not-yet-executable and let
            -- mason-lspconfig's automatic_enable wire them up after install.
            local function cmd_executable(cmd)
                if type(cmd) == "table" and cmd[1] then
                    return vim.fn.executable(cmd[1]) == 1
                elseif type(cmd) == "string" then
                    return vim.fn.executable(cmd) == 1
                end
                return false
            end

            local to_install = {}
            for server, server_opts in pairs(opts.servers) do
                if server_opts then
                    local enabled = (server_opts == true) or (server_opts.enabled ~= false)
                    if enabled then
                        if server_opts ~= true then
                            vim.lsp.config(server, server_opts)
                        end
                        -- Only enable now if the binary is already on $PATH.
                        -- Otherwise mason-lspconfig's automatic_enable picks
                        -- it up after install, avoiding noisy spawn errors
                        -- on first launch when mason hasn't caught up yet.
                        local cfg = vim.lsp.config[server]
                        if cfg and cmd_executable(cfg.cmd) then
                            vim.lsp.enable(server)
                        end
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

            -- Defer mason install setup until after UI is ready. We rely on
            -- mason-lspconfig's automatic_enable to wire up LSPs that mason
            -- installs after this point (it listens for install:success and
            -- calls vim.lsp.enable then). Servers already on $PATH were
            -- enabled eagerly above; vim.lsp.enable is idempotent so a
            -- duplicate from automatic_enable is harmless.
            vim.api.nvim_create_autocmd("VimEnter", {
                once = true,
                callback = function()
                    vim.schedule(function()
                        require("mason-lspconfig").setup({
                            ensure_installed = to_install,
                            automatic_enable = true,
                        })
                    end)
                end,
            })
        end,
    },
}
