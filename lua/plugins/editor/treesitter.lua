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
                "query",
                "regex",
                -- Diff / comments / markup
                "diff",
                "comment",
                "xml",
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

            -- Re-fire FileType for loaded buffers whose lang is in `langset`. The
            -- language.add check also guards markdown's ftplugin assert.
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
                -- install() returns a Task; re-fire FileType once every parser has landed.
                ts.install(missing):await(vim.schedule_wrap(function()
                    local set = {}
                    for _, lang in ipairs(missing) do
                        set[lang] = true
                    end
                    pcall(attach_langs, set)
                end))
            end
        end,
    },
}
