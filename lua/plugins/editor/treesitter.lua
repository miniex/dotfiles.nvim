return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        opts = {
            -- Sorted by language category, then family, then first-appeared.
            ensure_installed = {
                -- Shell
                "bash",
                "fish",
                -- Systems
                "c",
                "cpp",
                "go",
                "rust",
                "zig",
                -- Scripting
                "python",
                "lua",
                "elixir",
                "ocaml",
                "ocaml_interface",
                -- Web
                "html",
                "css",
                "scss",
                "javascript",
                "typescript",
                "tsx",
                "templ",
                "heex",
                "eex",
                -- API / Query
                "graphql",
                -- Shaders
                "wgsl",
                "glsl",
                "hlsl",
                -- Database
                "sql",
                -- Data / Config
                "json",
                "json5",
                "yaml",
                "proto",
                "toml",
                "ron",
                -- Markup
                "markdown",
                "markdown_inline",
                "typst",
                -- Build / Infra
                "cmake",
                "nix",
                "dockerfile",
                "just",
                "hcl",
                "terraform",
                "helm",
                -- Editor
                "vim",
                "vimdoc",
            },
        },
        config = function(_, opts)
            local ts = require("nvim-treesitter")
            ts.setup({})

            vim.treesitter.language.register("json", "jsonc")
            vim.treesitter.language.register("bash", { "sh", "zsh" })

            -- Incremental selection (main branch dropped the module). Stack drives gnM shrink.
            local function node_to_range(node)
                local srow, scol, erow, ecol = node:range()
                return srow, scol, erow, ecol
            end

            local function select_range(srow, scol, erow, ecol)
                vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
                vim.cmd("normal! v")
                -- selection is end-exclusive on columns; step back if at col 0
                if ecol == 0 then
                    vim.api.nvim_win_set_cursor(0, { erow, vim.v.maxcol })
                else
                    vim.api.nvim_win_set_cursor(0, { erow + 1, ecol - 1 })
                end
            end

            local stack_key = "_ts_incsel_stack"

            local function init_selection()
                local node = vim.treesitter.get_node()
                if not node then
                    return
                end
                vim.w[stack_key] = { { node_to_range(node) } }
                select_range(node_to_range(node))
            end

            local function node_incremental()
                local stack = vim.w[stack_key]
                if not stack or #stack == 0 then
                    init_selection()
                    return
                end
                local top = stack[#stack]
                local node = vim.treesitter.get_node({ pos = { top[1], top[2] } })
                if not node then
                    return
                end
                -- walk up until we get a strictly larger range
                while node do
                    local sr, sc, er, ec = node_to_range(node)
                    if
                        sr < top[1]
                        or er > top[3]
                        or (sr == top[1] and sc < top[2])
                        or (er == top[3] and ec > top[4])
                    then
                        -- Shallow copy: range tuples are immutable, no deepcopy needed.
                        local new_stack = vim.list_extend({}, stack)
                        table.insert(new_stack, { sr, sc, er, ec })
                        vim.w[stack_key] = new_stack
                        select_range(sr, sc, er, ec)
                        return
                    end
                    node = node:parent()
                end
            end

            local function node_decremental()
                local stack = vim.w[stack_key]
                if not stack or #stack <= 1 then
                    return
                end
                local new_stack = vim.list_extend({}, stack)
                table.remove(new_stack)
                vim.w[stack_key] = new_stack
                local top = new_stack[#new_stack]
                select_range(top[1], top[2], top[3], top[4])
            end

            vim.keymap.set("n", "gnn", init_selection, { desc = "TS: init incremental selection" })
            vim.keymap.set("x", "gnm", node_incremental, { desc = "TS: expand to parent node" })
            vim.keymap.set("x", "gnM", node_decremental, { desc = "TS: shrink to child node" })

            -- Set indentexpr for buffers attached by the early autocmd
            -- (which runs before this plugin loaded).
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.treesitter.highlighter.active[buf] then
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end

            -- Re-fire FileType only for loadable buffers in `langset` (just-installed
            -- langs) — avoids a per-tick FileType storm across all buffers. The
            -- loadable check also guards markdown's ftplugin assert.
            local function attach_langs(langset)
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(buf) then
                        local ft = vim.bo[buf].filetype
                        if ft and ft ~= "" then
                            local lang = vim.treesitter.language.get_lang(ft) or ft
                            if langset[lang] and pcall(vim.treesitter.language.add, lang) then
                                pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = buf, modeline = false })
                            end
                        end
                    end
                end
            end

            local ok, installed = pcall(ts.get_installed, "parsers")
            local missing
            if ok and type(installed) == "table" then
                local have = {}
                for _, lang in ipairs(installed) do
                    have[lang] = true
                end
                missing = {}
                for _, lang in ipairs(opts.ensure_installed) do
                    if not have[lang] then
                        table.insert(missing, lang)
                    end
                end
            else
                missing = opts.ensure_installed
            end

            if #missing > 0 then
                vim.schedule(function()
                    ts.install(missing)
                    local pending = {}
                    for _, lang in ipairs(missing) do
                        pending[lang] = true
                    end
                    -- Re-fire FileType as parsers finish installing; pcall so a throw can't leak the timer.
                    local attempts = 0
                    local timer = vim.uv.new_timer()
                    if not timer then
                        pcall(attach_langs, pending)
                        return
                    end
                    timer:start(
                        2000,
                        2000,
                        vim.schedule_wrap(function()
                            attempts = attempts + 1
                            local ok_chk, inst = pcall(ts.get_installed, "parsers")
                            if ok_chk and type(inst) == "table" then
                                local have = {}
                                for _, lang in ipairs(inst) do
                                    have[lang] = true
                                end
                                -- Only attach langs that just landed this tick; drop them from pending.
                                local newly = {}
                                for lang in pairs(pending) do
                                    if have[lang] then
                                        newly[lang] = true
                                        pending[lang] = nil
                                    end
                                end
                                if next(newly) ~= nil then
                                    pcall(attach_langs, newly)
                                end
                            end
                            -- Stop once every parser landed (pending empty) or we give up.
                            if next(pending) == nil or attempts >= 15 then
                                timer:stop()
                                timer:close()
                            end
                        end)
                    )
                end)
            end
        end,
    },
}
