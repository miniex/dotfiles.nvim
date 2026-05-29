-- LSP: native discovery (lsp/<server>.lua) gated by langs × lang_servers.
local drift_warned = false
local cached_servers
local function enabled_servers()
    -- Memoized + sorted: called twice (mason opts + config), and pairs() order
    -- is otherwise nondeterministic across runs.
    if cached_servers then
        return cached_servers
    end
    local langs = require("config.langs")
    local map = require("config.lang_servers")
    local out, seen, undefined = {}, {}, {}
    for lang, on in pairs(langs) do
        if on then
            -- A missing key (vs an intentional empty {} like ron/rust) means an
            -- enabled lang would silently get no LSP — surface the drift once.
            if map[lang] == nil then
                undefined[#undefined + 1] = lang
            end
            for _, s in ipairs(map[lang] or {}) do
                if not seen[s] then
                    seen[s] = true
                    out[#out + 1] = s
                end
            end
        end
    end
    if #undefined > 0 and not drift_warned then
        drift_warned = true
        vim.schedule(function()
            vim.notify(
                "Enabled langs missing from lang_servers.lua: " .. table.concat(undefined, ", "),
                vim.log.levels.WARN,
                { title = "config.lang_servers" }
            )
        end)
    end
    table.sort(out)
    cached_servers = out
    return out
end

return {
    {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = {
            ui = {
                border = vim.g.flower_border,
                width = 0.85,
                height = 0.85,
                icons = { package_installed = "✓", package_pending = "✿", package_uninstalled = "·" },
            },
        },
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
            -- VeryLazy is post-VimEnter; we trigger run_on_start() manually below.
            run_on_start = false,
            start_delay = 3000,
            -- No debounce: it would skip the whole check for hours, so a newly
            -- enabled lang's tools wouldn't auto-install. auto_update=false keeps
            -- it to missing-only (no churn).
        },
        config = function(_, opts)
            require("mason-tool-installer").setup(opts)
            require("mason-tool-installer").run_on_start()
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        -- SchemaStore: required by lsp/jsonls.lua + lsp/yamlls.lua before_init.
        dependencies = { "b0o/SchemaStore.nvim" },
        opts = { inlay_hints = { enabled = true } },
        config = function(_, opts)
            if vim.fn.has("nvim-0.11") ~= 1 then
                vim.notify("LSP setup needs nvim 0.11+", vim.log.levels.ERROR)
                return
            end

            -- Advertise blink.cmp's extra capabilities (snippets, resolve) to
            -- every server; native LSP merges this "*" config over its defaults.
            local capabilities = {}
            local ok_blink, blink = pcall(require, "blink.cmp")
            if ok_blink then
                capabilities = blink.get_lsp_capabilities({}, false)
            end
            vim.lsp.config("*", { capabilities = capabilities, root_markers = { ".git" } })

            -- virtual_text is off — tiny-inline-diagnostic owns it.
            vim.diagnostic.config({
                virtual_text = false,
                update_in_insert = false,
                underline = true,
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
                    header = "",
                    prefix = "",
                    title = " ✿ diagnostics ✿ ",
                    title_pos = "center",
                },
            })

            -- Per-client, capability-gated; runs on EVERY attach so wiring isn't
            -- tied to attach order (e.g. ruff before basedpyright). Buffer-global
            -- augroups are guarded to create once per buffer.
            local function setup_client_features(client, bufnr)
                if opts.inlay_hints.enabled and client:supports_method("textDocument/inlayHint") then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    if not vim.b[bufnr]._lsp_inlay_done then
                        vim.b[bufnr]._lsp_inlay_done = true
                        -- Drop inlay hints during insert to reduce LSP traffic.
                        local hg = vim.api.nvim_create_augroup("lsp-inlay-hint-insert-" .. bufnr, { clear = true })
                        vim.api.nvim_create_autocmd("InsertEnter", {
                            buffer = bufnr,
                            group = hg,
                            callback = function()
                                if vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) then
                                    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
                                    vim.b[bufnr]._inlay_hint_was_on = true
                                end
                            end,
                        })
                        vim.api.nvim_create_autocmd("InsertLeave", {
                            buffer = bufnr,
                            group = hg,
                            callback = function()
                                if vim.b[bufnr]._inlay_hint_was_on then
                                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                                    vim.b[bufnr]._inlay_hint_was_on = nil
                                end
                            end,
                        })
                    end
                end
                if client:supports_method("textDocument/codeLens") then
                    vim.lsp.codelens.enable(true, { bufnr = bufnr })
                    if not vim.b[bufnr]._lsp_codelens_done then
                        vim.b[bufnr]._lsp_codelens_done = true
                        -- codelens.enable wires LspAttach/BufEnter/InsertLeave; add
                        -- BufWritePost to catch new testables/run lenses after save.
                        local cl_group = vim.api.nvim_create_augroup("lsp-codelens-" .. bufnr, { clear = true })
                        vim.api.nvim_create_autocmd("BufWritePost", {
                            buffer = bufnr,
                            group = cl_group,
                            callback = function()
                                vim.lsp.codelens.refresh({ bufnr = bufnr })
                            end,
                        })
                    end
                end
                if client:supports_method("textDocument/documentHighlight") and not vim.b[bufnr]._lsp_dochl_done then
                    vim.b[bufnr]._lsp_dochl_done = true
                    local g = vim.api.nvim_create_augroup("lsp-doc-hl-" .. bufnr, { clear = true })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = bufnr,
                        group = g,
                        callback = vim.lsp.buf.document_highlight,
                    })
                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
                        buffer = bufnr,
                        group = g,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
                if vim.lsp.linked_editing_range and client:supports_method("textDocument/linkedEditingRange") then
                    pcall(vim.lsp.linked_editing_range.enable, true, { bufnr = bufnr })
                end
            end

            local group = vim.api.nvim_create_augroup("lsp-attach-keys", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = group,
                callback = function(args)
                    local bufnr = args.buf
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client then
                        setup_client_features(client, bufnr)
                    end

                    -- Keymaps are buffer-global: set once on the first attach.
                    if vim.b[bufnr]._lsp_keys_done then
                        return
                    end
                    vim.b[bufnr]._lsp_keys_done = true

                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                    end

                    -- Intentional aliases over 0.11+ defaults (grr/gri/grn/gra/gK)
                    -- for muscle memory and which-key discovery.
                    map("n", "K", function()
                        vim.lsp.buf.hover({
                            border = vim.g.flower_border,
                            title = " ✿ hover ✿ ",
                            title_pos = "center",
                        })
                    end, "Hover")
                    map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
                    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
                    map("n", "gr", vim.lsp.buf.references, "References")
                    map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
                    map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")
                    map("n", "<leader>cc", vim.diagnostic.open_float, "Line Diagnostics")
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    local toggle_inlay = function()
                        local on = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
                        vim.lsp.inlay_hint.enable(not on, { bufnr = bufnr })
                    end
                    map("n", "<leader>ci", toggle_inlay, "Toggle Inlay Hints")
                    map("n", "<leader>uh", toggle_inlay, "Toggle Inlay Hints")
                    map("n", "<leader>cL", vim.lsp.codelens.run, "Run CodeLens")
                    map("n", "<leader>cs", "<cmd>LspRestart<cr>", "LSP Restart")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                    map("i", "<C-k>", function()
                        vim.lsp.buf.signature_help({
                            border = vim.g.flower_border,
                            title = " ✿ signature ✿ ",
                            title_pos = "center",
                        })
                    end, "Signature Help")
                end,
            })

            local servers = enabled_servers()

            -- Defer ~20 executable() stats off the first-BufReadPre path; LSPs attach a tick later.
            vim.schedule(function()
                local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
                local current_path = vim.env.PATH or ""
                if not current_path:find(mason_bin, 1, true) then
                    vim.env.PATH = mason_bin .. ":" .. current_path
                end

                local function cmd_executable(cmd)
                    if type(cmd) == "table" and cmd[1] then
                        return vim.fn.executable(cmd[1]) == 1
                    elseif type(cmd) == "string" then
                        return vim.fn.executable(cmd) == 1
                    end
                    return false
                end

                for _, name in ipairs(servers) do
                    local cfg = vim.lsp.config[name]
                    if cfg and cmd_executable(cfg.cmd) then
                        vim.lsp.enable(name)
                    end
                end
            end)

            vim.api.nvim_create_autocmd("VimEnter", {
                group = vim.api.nvim_create_augroup("MasonLspconfigBootstrap", { clear = true }),
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
