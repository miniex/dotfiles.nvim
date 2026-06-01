return {
    "monaqa/dial.nvim",
    keys = {
        { "<C-a>", "<Plug>(dial-increment)", mode = { "n", "v" }, desc = "Increment" },
        { "<C-x>", "<Plug>(dial-decrement)", mode = { "n", "v" }, desc = "Decrement" },
        { "g<C-a>", "g<Plug>(dial-increment)", mode = "v", desc = "Increment (cumulative)" },
        { "g<C-x>", "g<Plug>(dial-decrement)", mode = "v", desc = "Decrement (cumulative)" },
    },
    config = function()
        local augend = require("dial.augend")
        local cyclic = function(elements, word)
            return augend.constant.new({ elements = elements, word = word or false, cyclic = true })
        end
        local bool = cyclic({ "true", "false" }, true)
        local logical = cyclic({ "&&", "||" })
        local eq = cyclic({ "==", "!=" })

        -- A filetype group replaces default entirely, so share the base augends.
        local common = {
            augend.integer.alias.decimal_int,
            augend.integer.alias.hex,
            augend.constant.alias.alpha,
            augend.constant.alias.Alpha,
            augend.date.alias["%Y-%m-%d"],
            augend.date.alias["%Y/%m/%d"],
            augend.date.alias["%H:%M"],
            augend.semver.alias.semver,
            bool,
            logical,
            eq,
        }

        require("dial.config").augends:register_group({
            default = common,
            typescript = vim.list_extend({ cyclic({ "let", "const" }, true) }, common),
            markdown = { augend.misc.alias.markdown_header },
        })

        local ft_group = {
            typescript = "typescript",
            typescriptreact = "typescript",
            javascript = "typescript",
            javascriptreact = "typescript",
            markdown = "markdown",
        }
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("DialFiletypeGroup", { clear = true }),
            pattern = vim.tbl_keys(ft_group),
            callback = function(args)
                vim.b[args.buf].dial_group = ft_group[vim.bo[args.buf].filetype]
            end,
        })
    end,
}
