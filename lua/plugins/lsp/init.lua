-- LSP: native discovery (lsp/<server>.lua) gated by langs × lang_servers.
local function enabled_servers()
    local langs = require("config.langs")
    local map = require("config.lang_servers")
    local out, seen = {}, {}
    for lang, on in pairs(langs) do
        if on then
            for _, s in ipairs(map[lang] or {}) do
                if not seen[s] then
                    seen[s] = true
                    out[#out + 1] = s
                end
            end
        end
    end
    return out
end

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
        opts_extend = { "ensure_installed" },
        opts = {
            ensure_installed = enabled_servers(),
            auto_update = false,
            run_on_start = true,
            start_delay = 3000,
            debounce_hours = 24,
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        -- SchemaStore: required by lsp/jsonls.lua + lsp/yamlls.lua before_init.
        dependencies = { "b0o/SchemaStore.nvim" },
        opts = { inlay_hints = { enabled = true } },
        config = function(_, opts)
            vim.lsp.config("*", { root_markers = { ".git" } })

            -- ◆ corner-flowered rounded border (damin echo).
            local flower_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
            flower_border[1] = "✿"
            flower_border[3] = "✿"
            flower_border[5] = "✿"
            flower_border[7] = "✿"
            vim.g.flower_border = flower_border

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
                float = { border = flower_border, source = "always", header = "", prefix = "" },
            })

            local group = vim.api.nvim_create_augroup("lsp-attach-keys", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = group,
                callback = function(args)
                    local bufnr = args.buf
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                    end

                    -- Intentional aliases over 0.11+ defaults (grr/gri/grn/gra/gK)
                    -- for muscle memory and which-key discovery.
                    map("n", "K", function()
                        vim.lsp.buf.hover({ border = vim.g.flower_border })
                    end, "Hover")
                    map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
                    map("n", "gr", vim.lsp.buf.references, "References")
                    map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
                    map("n", "<leader>cc", vim.diagnostic.open_float, "Line Diagnostics")
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    map("n", "<leader>ci", function()
                        local on = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
                        vim.lsp.inlay_hint.enable(not on, { bufnr = bufnr })
                    end, "Toggle Inlay Hints")
                    map("n", "<leader>cL", vim.lsp.codelens.run, "Run CodeLens")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                    map("i", "<C-k>", function()
                        vim.lsp.buf.signature_help({ border = vim.g.flower_border })
                    end, "Signature Help")

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client then
                        if opts.inlay_hints.enabled and client:supports_method("textDocument/inlayHint") then
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end
                        if client:supports_method("textDocument/codeLens") then
                            vim.lsp.codelens.enable(true, { bufnr = bufnr })
                        end
                    end
                end,
            })

            -- Drop inlay hints during insert to reduce LSP traffic.
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

            -- mason bin → PATH before checking executable (mason loads lazy).
            local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
            if not vim.env.PATH:find(mason_bin, 1, true) then
                vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
            end

            local function cmd_executable(cmd)
                if type(cmd) == "table" and cmd[1] then
                    return vim.fn.executable(cmd[1]) == 1
                elseif type(cmd) == "string" then
                    return vim.fn.executable(cmd) == 1
                end
                return false
            end

            -- Enable now if binary on PATH; rest via mason-lspconfig automatic_enable.
            local servers = enabled_servers()
            for _, name in ipairs(servers) do
                local cfg = vim.lsp.config[name]
                if cfg and cmd_executable(cfg.cmd) then
                    vim.lsp.enable(name)
                end
            end

            -- Re-fire FileType for buffers loaded before config ran.
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

            vim.api.nvim_create_autocmd("VimEnter", {
                once = true,
                callback = function()
                    vim.schedule(function()
                        require("mason-lspconfig").setup({
                            ensure_installed = servers,
                            automatic_enable = true,
                        })
                    end)
                end,
            })
        end,
    },
}
