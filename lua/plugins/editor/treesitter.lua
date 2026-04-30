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
                end)
            end

            local function attach(bufnr)
                local ft = vim.bo[bufnr].filetype
                if not ft or ft == "" then
                    return
                end
                local lang = vim.treesitter.language.get_lang(ft) or ft
                if not lang or lang == "" then
                    return
                end
                if not pcall(vim.treesitter.start, bufnr, lang) then
                    return
                end
                vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter-attach", { clear = true }),
                callback = function(args)
                    attach(args.buf)
                end,
            })

            -- Buffers loaded before this autocmd was registered (nvim file.lua args)
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) then
                    attach(buf)
                end
            end
        end,
    },
}
