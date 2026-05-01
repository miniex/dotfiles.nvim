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
                -- Scripting
                "python",
                "lua",
                -- Web
                "html",
                "css",
                "javascript",
                "typescript",
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
                -- Build / Infra
                "cmake",
                "nix",
                "dockerfile",
                "just",
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

            -- Set indentexpr for buffers attached by the early autocmd
            -- (which runs before this plugin loaded).
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.treesitter.highlighter.active[buf] then
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end

            local function attach_all()
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(buf) then
                        vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
                    end
                end
            end

            local ok, installed = pcall(ts.get_installed, "parsers")
            local missing
            if ok and type(installed) == "table" then
                missing = {}
                for _, lang in ipairs(opts.ensure_installed) do
                    if not vim.tbl_contains(installed, lang) then
                        table.insert(missing, lang)
                    end
                end
            else
                missing = opts.ensure_installed
            end

            if #missing > 0 then
                vim.schedule(function()
                    ts.install(missing)
                    -- Re-fire FileType for loaded buffers as parsers finish installing
                    local attempts = 0
                    local timer = assert(vim.uv.new_timer())
                    timer:start(
                        2000,
                        2000,
                        vim.schedule_wrap(function()
                            attempts = attempts + 1
                            attach_all()
                            if attempts >= 15 then
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
