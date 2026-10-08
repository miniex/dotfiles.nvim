-- LSP: native discovery (after/lsp/<server>.lua) gated by langs × lang_servers.
local drift_warned = false
local cached_servers
local function enabled_servers()
    -- Memoized + sorted: called twice (mason opts + config), and pairs() order
    -- is otherwise nondeterministic across runs.
    if cached_servers then
        return cached_servers
    end
    local ok_langs, langs = pcall(require, "config.langs")
    local ok_map, map = pcall(require, "config.lang_servers")
    if not ok_langs or not ok_map then
        vim.schedule(function()
            vim.notify("Failed to load lang config; no LSP servers enabled", vim.log.levels.ERROR, { title = "lsp" })
        end)
        cached_servers = {}
        return cached_servers
    end
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
    -- typos_lsp is language-agnostic, so it's always on rather than per-lang.
    if not seen["typos_lsp"] then
        out[#out + 1] = "typos_lsp"
    end
    table.sort(out)
    cached_servers = out
    return out
end

return {
    {
        "mason-org/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        -- mason.nvim has no title option; inject the flower title on its FileType.
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "mason",
                group = vim.api.nvim_create_augroup("MasonFlowerTitle", { clear = true }),
                callback = function()
                    vim.schedule(function()
                        pcall(vim.api.nvim_win_set_config, vim.api.nvim_get_current_win(), {
                            title = vim.g.flower_title("mason"),
                            title_pos = "center",
                        })
                    end)
                end,
            })
        end,
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
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        cmd = { "LspInstall", "LspUninstall" },
        -- No ensure_installed: mason-tool-installer owns installs. We enable servers
        -- ourselves (lang + executable gated); automatic_enable would enable every package.
        opts = { automatic_enable = false },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
        -- Loads mason + mason-lspconfig (6-16ms): keep it 3s off the startup path,
        -- and out of headless runs (no UIEnter).
        init = function()
            vim.api.nvim_create_autocmd("UIEnter", {
                once = true,
                callback = function()
                    vim.defer_fn(function()
                        require("lazy").load({ plugins = { "mason-tool-installer.nvim" } })
                    end, 3000)
                end,
            })
        end,
        opts_extend = { "ensure_installed" },
        -- Function form defers enabled_servers() off the lazy spec-build path.
        opts = function()
            return {
                ensure_installed = enabled_servers(),
                auto_update = false,
                -- Must be true, or the run_on_start() call in config() no-ops (it gates on this flag).
                run_on_start = true,
                -- No debounce: it would skip the whole check for hours, so a newly
                -- enabled lang's tools wouldn't auto-install. auto_update=false keeps
                -- it to missing-only (no churn).
            }
        end,
        config = function(_, opts)
            -- Lang specs share tools (codelldb); duplicates would race two installs.
            -- Compare by mason package name: yamlls and yaml-language-server are one tool.
            local ok_map, mlsp = pcall(require, "mason-lspconfig")
            local to_pkg = ok_map and mlsp.get_mappings().lspconfig_to_package or {}
            local seen = {}
            opts.ensure_installed = vim.tbl_filter(function(t)
                local name = type(t) == "table" and t[1] or t
                name = to_pkg[name] or name
                if seen[name] then
                    return false
                end
                seen[name] = true
                return true
            end, opts.ensure_installed or {})
            require("mason-tool-installer").setup(opts)
            require("mason-tool-installer").run_on_start()
            -- auto_update stays off; surface a one-shot "updates available" toast (missing tools → run_on_start).
            vim.defer_fn(function()
                local ok, registry = pcall(require, "mason-registry")
                if not ok then
                    return
                end
                -- refresh() loads the index once; get_*_version() are then local/sync.
                registry.refresh(function()
                    local outdated = {}
                    for _, p in ipairs(registry.get_installed_packages()) do
                        local oi, installed = pcall(function()
                            return p:get_installed_version()
                        end)
                        local ol, latest = pcall(function()
                            return p:get_latest_version()
                        end)
                        if oi and ol and installed and latest and installed ~= latest then
                            outdated[#outdated + 1] = p.name
                        end
                    end
                    if #outdated > 0 then
                        table.sort(outdated)
                        vim.schedule(function()
                            vim.notify(
                                ("%d Mason tool(s) have updates — :MasonToolsUpdate\n%s"):format(
                                    #outdated,
                                    table.concat(outdated, ", ")
                                ),
                                vim.log.levels.INFO,
                                { title = "Mason" }
                            )
                        end)
                    end
                end)
            end, 8000)
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        -- SchemaStore: required by after/lsp/jsonls.lua + after/lsp/yamlls.lua before_init.
        dependencies = { "b0o/SchemaStore.nvim" },
        opts = { inlay_hints = { enabled = true } },
        config = function(_, opts)
            if vim.fn.has("nvim-0.12") ~= 1 then
                vim.notify("LSP setup needs nvim 0.12+", vim.log.levels.ERROR)
                return
            end

            -- blink.cmp's completion capabilities (blink/cmp/sources/lib get_lsp_capabilities),
            -- inlined: require("blink.cmp") here would pull blink + LuaSnip (~23ms) into
            -- every file open instead of the first InsertEnter. Native LSP merges "*" over defaults.
            local capabilities = {
                textDocument = {
                    completion = {
                        completionItem = {
                            snippetSupport = true,
                            commitCharactersSupport = false,
                            documentationFormat = { "markdown", "plaintext" },
                            deprecatedSupport = true,
                            preselectSupport = false,
                            tagSupport = { valueSet = { 1 } },
                            insertReplaceSupport = true,
                            resolveSupport = {
                                properties = { "documentation", "detail", "additionalTextEdits", "command", "data" },
                            },
                            insertTextModeSupport = { valueSet = { 1 } },
                            labelDetailsSupport = true,
                        },
                        completionList = {
                            itemDefaults = {
                                "commitCharacters",
                                "editRange",
                                "insertTextFormat",
                                "insertTextMode",
                                "data",
                            },
                        },
                        contextSupport = true,
                        insertTextMode = 1,
                    },
                },
                -- File watching: nvim keeps it off on Linux/BSD; without inotifywait its
                -- fallback walks every dir (~200ms stall on open), so opt in only with it.
                workspace = {
                    didChangeWatchedFiles = { dynamicRegistration = vim.fn.executable("inotifywait") == 1 },
                },
            }
            vim.lsp.config("*", { capabilities = capabilities, root_markers = { ".git" } })

            -- Vue (Volar hybrid): attach vtsls to .vue + load @vue/typescript-plugin when
            -- installed. Via vim.lsp.config so filetypes outrank lspconfig's bundled list.
            local vue_loc = vim.fn.stdpath("data")
                .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
            if vim.uv.fs_stat(vue_loc) then
                vim.lsp.config("vtsls", {
                    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
                    settings = {
                        vtsls = {
                            tsserver = {
                                globalPlugins = {
                                    {
                                        name = "@vue/typescript-plugin",
                                        location = vue_loc,
                                        languages = { "vue" },
                                        configNamespace = "typescript",
                                    },
                                },
                            },
                        },
                    },
                })
            end

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

            -- Big-file guard: skip LSP features that re-request the whole document per idle/change.
            -- Cached per buffer: runs on every attach, before the _done gates.
            local function buf_is_big(buf)
                local cached = vim.b[buf]._lsp_buf_is_big
                if cached ~= nil then
                    return cached
                end
                local name = vim.api.nvim_buf_get_name(buf)
                local big = name ~= "" and vim.fn.getfsize(name) > 1 * 1024 * 1024 -- 1 MiB
                if not big then
                    local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
                    big = first ~= nil and #first > 2000
                end
                vim.b[buf]._lsp_buf_is_big = big
                return big
            end

            -- Servers whose semantic tokens clash with treesitter. Disabled here, not via
            -- the server's on_attach, so its bundled on_attach (e.g. pyright cmds) still runs.
            local SEMANTIC_TOKENS_OFF = { basedpyright = true, vtsls = true, clangd = true }
            -- client_id -> on/off set by <leader>uy; wins over SEMANTIC_TOKENS_OFF on later attaches.
            local semantic_user = {}

            -- Per-client, capability-gated; runs on EVERY attach so wiring isn't
            -- tied to attach order (e.g. ruff before basedpyright). Buffer-global
            -- augroups are guarded to create once per buffer.
            local function setup_client_features(client, bufnr)
                -- Per client, not per buffer: a bufnr filter also kills tokens from
                -- other servers on the buffer (vue_ls next to vtsls).
                if
                    SEMANTIC_TOKENS_OFF[client.name]
                    and semantic_user[client.id] == nil
                    and vim.lsp.semantic_tokens.is_enabled({ client_id = client.id })
                then
                    pcall(vim.lsp.semantic_tokens.enable, false, { client_id = client.id })
                end
                -- Buffer-local: lspconfig's clangd on_attach creates the command.
                if client.name == "clangd" and not vim.b[bufnr]._clangd_keys_done then
                    vim.b[bufnr]._clangd_keys_done = true
                    vim.keymap.set("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", {
                        buffer = bufnr,
                        silent = true,
                        desc = "Switch Source/Header (C/C++)",
                    })
                end
                if
                    opts.inlay_hints
                    and opts.inlay_hints.enabled
                    and client:supports_method("textDocument/inlayHint", bufnr)
                then
                    if not vim.b[bufnr]._lsp_inlay_done then
                        vim.b[bufnr]._lsp_inlay_done = true
                        -- Enable once: re-enabling on a 2nd client / :lsp restart would override the user's toggle.
                        if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
                            vim.b[bufnr]._inlay_hint_was_on = true -- InsertLeave turns it on
                        else
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end
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
                if not buf_is_big(bufnr) and client:supports_method("textDocument/codeLens", bufnr) then
                    if not vim.b[bufnr]._lsp_codelens_done then
                        vim.b[bufnr]._lsp_codelens_done = true
                        vim.lsp.codelens.enable(true, { bufnr = bufnr })
                        local cl_group = vim.api.nvim_create_augroup("lsp-codelens-" .. bufnr, { clear = true })
                        -- Pause during insert: codelens refreshes per change (buf on_lines), like inlay hints.
                        vim.api.nvim_create_autocmd("InsertEnter", {
                            buffer = bufnr,
                            group = cl_group,
                            callback = function()
                                if vim.lsp.codelens.is_enabled({ bufnr = bufnr }) then
                                    vim.lsp.codelens.enable(false, { bufnr = bufnr })
                                end
                            end,
                        })
                        vim.api.nvim_create_autocmd("InsertLeave", {
                            buffer = bufnr,
                            group = cl_group,
                            callback = function()
                                if not vim.lsp.codelens.is_enabled({ bufnr = bufnr }) then
                                    vim.lsp.codelens.enable(true, { bufnr = bufnr })
                                end
                            end,
                        })
                    end
                end
                if
                    vim.lsp.linked_editing_range
                    and client:supports_method("textDocument/linkedEditingRange", bufnr)
                    and not vim.b[bufnr]._lsp_linked_edit_done
                then
                    -- enable() only honors client_id; { bufnr = ... } silently toggles globally.
                    vim.b[bufnr]._lsp_linked_edit_done = true
                    pcall(vim.lsp.linked_editing_range.enable, true, { client_id = client.id })
                end
                -- nvim routes gq/gw through the LSP formatter by default; prose reflows
                -- better with the built-in.
                local ft = vim.bo[bufnr].filetype
                if
                    (ft == "markdown" or ft == "gitcommit" or ft == "gitrebase" or ft == "text")
                    and vim.bo[bufnr].formatexpr == "v:lua.vim.lsp.formatexpr()"
                then
                    vim.bo[bufnr].formatexpr = ""
                end
            end

            -- Prefer fzf-lua's LSP pickers (fuzzy on many, auto-jump on one) over
            -- the native quickfix dump; fall back to native if fzf-lua isn't loaded.
            local function lsp_pick(method, native)
                return function()
                    local ok, fzf = pcall(require, "fzf-lua")
                    if ok and fzf[method] then
                        fzf[method]()
                    else
                        native()
                    end
                end
            end

            -- Drop the 0.11+ default gr* maps: global + share the `gr` prefix with our
            -- buffer-local gr (References) → timeoutlen wait on every `gr`. Remapped to:
            -- grr→gr, gri→gI, grt→gy, gra→<leader>ca, grx→<leader>cL, grn→<leader>rn.
            for _, k in ipairs({ "grn", "grr", "gri", "grt", "grx" }) do
                pcall(vim.keymap.del, "n", k)
            end
            pcall(vim.keymap.del, { "n", "x" }, "gra")

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

                    -- Replacements for the deleted 0.11+ gr* defaults; which-key-discoverable.
                    map("n", "K", function()
                        vim.lsp.buf.hover({
                            border = vim.g.flower_border,
                            title = " ✿ hover ✿ ",
                            title_pos = "center",
                        })
                    end, "Hover")
                    map("n", "gd", lsp_pick("lsp_definitions", vim.lsp.buf.definition), "Goto Definition")
                    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
                    map("n", "gr", lsp_pick("lsp_references", vim.lsp.buf.references), "References")
                    map("n", "gI", lsp_pick("lsp_implementations", vim.lsp.buf.implementation), "Goto Implementation")
                    map("n", "gy", lsp_pick("lsp_typedefs", vim.lsp.buf.type_definition), "Goto Type Definition")
                    -- Call/type hierarchy (gci/gco clash with the gc comment operator → <leader>c*).
                    map("n", "<leader>cI", lsp_pick("lsp_incoming_calls", vim.lsp.buf.incoming_calls), "Incoming Calls")
                    map("n", "<leader>cG", lsp_pick("lsp_outgoing_calls", vim.lsp.buf.outgoing_calls), "Outgoing Calls")
                    map("n", "<leader>cH", function()
                        vim.ui.select({ "subtypes", "supertypes" }, { prompt = "Type hierarchy" }, function(c)
                            if c then
                                vim.lsp.buf.typehierarchy(c)
                            end
                        end)
                    end, "Type Hierarchy")
                    map("n", "<leader>cc", vim.diagnostic.open_float, "Line Diagnostics")
                    -- tiny-code-action: picker with per-action diff preview (fzf-lua backend).
                    map({ "n", "x" }, "<leader>ca", function()
                        require("tiny-code-action").code_action()
                    end, "Code Action")
                    -- Inlay toggle (<leader>ci/uh) lives in snacks.lua.
                    map("n", "<leader>cL", vim.lsp.codelens.run, "Run CodeLens")
                    -- Prefer one formatter per ft when >1 client formats (e.g. python:
                    -- ruff). Single-formatter buffers fall through unfiltered.
                    local format_prefs = { python = "ruff" }
                    local function do_format(range)
                        local b = vim.api.nvim_get_current_buf()
                        local formatters = vim.tbl_filter(function(c)
                            return c:supports_method("textDocument/formatting", b)
                        end, vim.lsp.get_clients({ bufnr = b }))
                        local opts_fmt = { async = true, bufnr = b, range = range }
                        local preferred = format_prefs[vim.bo[b].filetype]
                        local has_preferred = preferred
                            and vim.iter(formatters):any(function(c)
                                return c.name == preferred
                            end)
                        if #formatters > 1 and has_preferred then
                            opts_fmt.filter = function(c)
                                return c.name == preferred
                            end
                        end
                        vim.lsp.buf.format(opts_fmt)
                    end
                    map("n", "<leader>cf", function()
                        do_format()
                    end, "Format (LSP)")
                    map("x", "<leader>cf", function()
                        vim.cmd("normal! \27") -- leave visual so '< / '> marks are set
                        do_format({
                            start = vim.api.nvim_buf_get_mark(0, "<"),
                            ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
                        })
                    end, "Format range (LSP)")
                    map("n", "<leader>cs", "<cmd>lsp restart<cr>", "LSP Restart")
                    -- inc-rename: load before typing; lazy's :IncRename stub has no preview.
                    map("n", "<leader>rn", function()
                        require("inc_rename")
                        local w = vim.fn.expand("<cword>")
                        if w ~= "" then
                            vim.api.nvim_feedkeys(":IncRename " .. w, "n", false)
                        end
                    end, "Rename")
                    -- Semantic tokens can clash with treesitter highlight. Toggles this buffer's
                    -- clients (all their buffers): SEMANTIC_TOKENS_OFF disables by client_id,
                    -- and a bufnr toggle is ANDed with that flag, so it couldn't turn them back on.
                    map("n", "<leader>uy", function()
                        local b = vim.api.nvim_get_current_buf()
                        local clients = vim.tbl_filter(function(c)
                            return c:supports_method("textDocument/semanticTokens/full", b)
                        end, vim.lsp.get_clients({ bufnr = b }))
                        local on = false
                        for _, c in ipairs(clients) do
                            on = on or vim.lsp.semantic_tokens.is_enabled({ bufnr = b, client_id = c.id })
                        end
                        vim.lsp.semantic_tokens.enable(not on, { bufnr = b })
                        for _, c in ipairs(clients) do
                            semantic_user[c.id] = not on
                            vim.lsp.semantic_tokens.enable(not on, { client_id = c.id })
                        end
                    end, "Toggle Semantic Tokens")
                    -- Signature help: blink owns it (auto popup + <C-k> in completion.lua).
                end,
            })

            local servers = enabled_servers()

            -- Defer ~20 executable() stats off the first-BufReadPre path; LSPs attach a tick later.
            vim.schedule(function()
                local function cmd_executable(cmd)
                    if type(cmd) == "table" and cmd[1] then
                        return vim.fn.executable(cmd[1]) == 1
                    elseif type(cmd) == "string" then
                        return vim.fn.executable(cmd) == 1
                    elseif type(cmd) == "function" then
                        -- Function cmd (e.g. jsonls/yamlls) resolves its binary at runtime and
                        -- can't be stat'd here; enable and let the spawn fail quietly on a miss.
                        return true
                    end
                    return false
                end

                -- Our settings live in after/lsp/ so they merge after nvim-lspconfig's lsp/.
                for _, name in ipairs(servers) do
                    local cfg = vim.lsp.config[name]
                    if cfg and cmd_executable(cfg.cmd) then
                        vim.lsp.enable(name)
                    end
                end
            end)
        end,
    },
}
