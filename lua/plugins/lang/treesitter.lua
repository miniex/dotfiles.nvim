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
                "jsonc",
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
                ts.install(missing)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter-attach", { clear = true }),
                callback = function(args)
                    local bufnr = args.buf
                    local ft = vim.bo[bufnr].filetype
                    local lang = vim.treesitter.language.get_lang(ft) or ft
                    if not lang or lang == "" then
                        return
                    end
                    if not pcall(vim.treesitter.start, bufnr, lang) then
                        return
                    end
                    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
}
