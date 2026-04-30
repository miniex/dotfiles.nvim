return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "c",
                "cpp",
                "cmake",
                "css",
                "html",
                "javascript",
                "typescript",
                "json",
                "json5",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "rust",
                "ron",
                "toml",
                "vim",
                "vimdoc",
                "yaml",
            },
        },
        config = function(_, opts)
            local ts = require("nvim-treesitter")
            ts.setup({})

            vim.treesitter.language.register("json", "jsonc")

            local function has_parser(lang)
                return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) > 0
            end

            local function attach(bufnr)
                if not vim.api.nvim_buf_is_valid(bufnr) then
                    return
                end
                if vim.treesitter.highlighter.active[bufnr] then
                    return
                end
                local ft = vim.bo[bufnr].filetype
                if not ft or ft == "" then
                    return
                end
                local lang = vim.treesitter.language.get_lang(ft) or ft
                if not has_parser(lang) then
                    return
                end
                if not pcall(vim.treesitter.start, bufnr, lang) then
                    return
                end
                vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end

            local function attach_all()
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(buf) then
                        attach(buf)
                    end
                end
            end

            local group = vim.api.nvim_create_augroup("treesitter-attach", { clear = true })

            vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
                group = group,
                callback = function(args)
                    attach(args.buf)
                end,
            })

            attach_all()

            vim.api.nvim_create_autocmd("VimEnter", {
                group = group,
                once = true,
                callback = function()
                    vim.schedule(attach_all)
                end,
            })

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
