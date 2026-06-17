-- LSP: native discovery (lsp/<server>.lua) gated by langs × lang_servers.
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
    table.sort(out)
    -- typos_lsp is language-agnostic, so it's always on rather than per-lang.
    out[#out + 1] = "typos_lsp"
    cached_servers = out
    return out
end

return {
    {
        "williamboman/mason.nvim",
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
        -- Function form defers enabled_servers() off the lazy spec-build path.
        opts = function()
            return {
                ensure_installed = enabled_servers(),
                auto_update = false,
                -- Must be true, or the run_on_start() call in config() no-ops (it gates on this flag).
                run_on_start = true,
                start_delay = 3000,
                -- No debounce: it would skip the whole check for hours, so a newly
                -- enabled lang's tools wouldn't auto-install. auto_update=false keeps
                -- it to missing-only (no churn).
            }
        end,
        config = function(_, opts)
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
        -- SchemaStore: required by lsp/jsonls.lua + lsp/yamlls.lua before_init.
        dependencies = { "b0o/SchemaStore.nvim" },
        opts = { inlay_hints = { enabled = true } },
        config = function(_, opts)
            if vim.fn.has("nvim-0.12") ~= 1 then
                vim.notify("LSP setup needs nvim 0.12+", vim.log.levels.ERROR)
                return
            end

            -- Advertise blink.cmp's extra capabilities (snippets, resolve) to
            -- every server; native LSP merges this "*" config over its defaults.
            local capabilities = {}
            local ok_blink, blink = pcall(require, "blink.cmp")
            if ok_blink then
                capabilities = blink.get_lsp_capabilities({}, false)
            end
            -- File watching: nvim defaults this off on Linux/BSD, so opt in for all servers.
            capabilities.workspace = capabilities.workspace or {}
            capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = true }
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
            local SEMANTIC_TOKENS_OFF = { basedpyright = true, vtsls = true }

            -- Per-client, capability-gated; runs on EVERY attach so wiring isn't
            -- tied to attach order (e.g. ruff before basedpyright). Buffer-global
            -- augroups are guarded to create once per buffer.
            local function setup_client_features(client, bufnr)
                -- Once per buffer: re-disabling on a 2nd attach would clobber a <leader>uy toggle.
                if SEMANTIC_TOKENS_OFF[client.name] and not vim.b[bufnr]._semantic_disabled then
                    vim.b[bufnr]._semantic_disabled = true
                    vim.schedule(function()
                        if vim.api.nvim_buf_is_valid(bufnr) then
                            pcall(vim.lsp.semantic_tokens.enable, false, { bufnr = bufnr })
                        end
                    end)
                end
                if
                    opts.inlay_hints
                    and opts.inlay_hints.enabled
                    and client:supports_method("textDocument/inlayHint", bufnr)
                then
                    if not vim.b[bufnr]._lsp_inlay_done then
                        vim.b[bufnr]._lsp_inlay_done = true
                        -- Enable once: re-enabling on a 2nd client / :LspRestart would override the user's toggle.
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
                                vim.lsp.codelens.enable(false, { bufnr = bufnr })
                            end,
                        })
                        vim.api.nvim_create_autocmd("InsertLeave", {
                            buffer = bufnr,
                            group = cl_group,
                            callback = function()
                                vim.lsp.codelens.enable(true, { bufnr = bufnr })
                            end,
                        })
                    end
                end
                if
                    not buf_is_big(bufnr)
                    and client:supports_method("textDocument/documentHighlight", bufnr)
                    and not vim.b[bufnr]._lsp_dochl_done
                then
                    vim.b[bufnr]._lsp_dochl_done = true
                    local g = vim.api.nvim_create_augroup("lsp-doc-hl-" .. bufnr, { clear = true })
                    -- Normal mode only; InsertEnter clears stale highlight (no per-keystroke clear in insert).
                    vim.api.nvim_create_autocmd("CursorHold", {
                        buffer = bufnr,
                        group = g,
                        callback = vim.lsp.buf.document_highlight,
                    })
                    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
                        buffer = bufnr,
                        group = g,
                        callback = vim.lsp.buf.clear_references,
                    })
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
                -- Route gq/gw through the LSP formatter (code only; prose reflows
                -- better with Neovim's built-in).
                if
                    client:supports_method("textDocument/rangeFormatting", bufnr)
                    and not vim.b[bufnr]._lsp_formatexpr_done
                then
                    local ft = vim.bo[bufnr].filetype
                    if ft ~= "markdown" and ft ~= "gitcommit" and ft ~= "gitrebase" and ft ~= "text" then
                        vim.b[bufnr]._lsp_formatexpr_done = true
                        vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
                    end
                end
                -- Color swatches (0.12) on documentColor-capable servers (colorizer owns
                -- hex). Capability can register post-init (cssls/tailwindcss), so poll —
                -- bounded to ~1s (4 × 250ms) since it always lands during init handshake.
                if vim.lsp.document_color and not vim.b[bufnr]["_doccolor_polling_" .. client.id] then
                    vim.b[bufnr]["_doccolor_polling_" .. client.id] = true
                    local cid, tries = client.id, 0
                    local function enable_color()
                        if not vim.api.nvim_buf_is_valid(bufnr) then
                            return
                        end
                        local c = vim.lsp.get_client_by_id(cid)
                        if c and c:supports_method("textDocument/documentColor", bufnr) then
                            pcall(vim.lsp.document_color.enable, true, { bufnr = bufnr })
                            vim.b[bufnr]["_doccolor_polling_" .. cid] = nil
                        elseif c and tries < 4 then
                            tries = tries + 1
                            vim.defer_fn(enable_color, 250)
                        else
                            -- client gone / gave up — clear so a fresh attach (restart) re-polls.
                            vim.b[bufnr]["_doccolor_polling_" .. cid] = nil
                        end
                    end
                    enable_color()
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
            -- grr→gr, gri→gi, grt→gy, gra→<leader>ca, grx→<leader>cL, grn→<leader>rn.
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
                    map("n", "gi", lsp_pick("lsp_implementations", vim.lsp.buf.implementation), "Goto Implementation")
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
                    map("n", "<leader>cs", "<cmd>LspRestart<cr>", "LSP Restart")
                    -- inc-rename: live in-buffer preview; :IncRename lazy-loads on use.
                    vim.keymap.set("n", "<leader>rn", function()
                        local w = vim.fn.expand("<cword>")
                        return w ~= "" and (":IncRename " .. w) or ""
                    end, { buffer = bufnr, expr = true, desc = "Rename" })
                    -- Semantic tokens can clash with treesitter highlight; toggle per buffer.
                    map("n", "<leader>uy", function()
                        local b = vim.api.nvim_get_current_buf()
                        local on = vim.lsp.semantic_tokens.is_enabled({ bufnr = b })
                        vim.lsp.semantic_tokens.enable(not on, { bufnr = b })
                    end, "Toggle Semantic Tokens")
                    -- Signature help: blink owns it (auto popup + <C-k> in completion.lua).
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
                    elseif type(cmd) == "function" then
                        -- Function cmd (e.g. jsonls/yamlls) resolves its binary at runtime and
                        -- can't be stat'd here; enable and let the spawn fail quietly on a miss.
                        return true
                    end
                    return false
                end

                -- nvim-lspconfig's bundled lsp/<name>.lua wins the rtp merge over ours for
                -- array keys (cmd/filetypes/root_markers); re-apply ours so it takes effect.
                local lsp_dir = vim.fn.stdpath("config") .. "/lsp/"
                for _, name in ipairs(servers) do
                    local ok_cfg, repo_cfg = pcall(dofile, lsp_dir .. name .. ".lua")
                    if ok_cfg and type(repo_cfg) == "table" then
                        vim.lsp.config(name, repo_cfg)
                    end
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
                            -- No ensure_installed: mason-tool-installer owns installs (would double-install).
                            -- We enable servers ourselves above (lang + executable gated);
                            -- automatic_enable = true would enable every installed package.
                            automatic_enable = false,
                        })
                    end)
                end,
            })
        end,
    },
}
