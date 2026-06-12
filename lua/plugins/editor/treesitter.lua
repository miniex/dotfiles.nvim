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
                "nim",
                -- Scripting
                "python",
                "lua",
                "elixir",
                "ocaml",
                "ocaml_interface",
                "php",
                "phpdoc",
                -- Web
                "html",
                "css",
                "scss",
                "javascript",
                "typescript",
                "tsx",
                "svelte",
                "vue",
                "astro",
                "templ",
                "heex",
                "eex",
                -- API / Query
                "graphql",
                "http",
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

            -- Node selection uses 0.12 native maps (an/in/]n/[n); mini-ai.lua moves
            -- its an/in → aN/iN to free them.

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
