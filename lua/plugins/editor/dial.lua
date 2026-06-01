return {
    "monaqa/dial.nvim",
    keys = {
        { "<C-a>", "<Plug>(dial-increment)", mode = { "n", "v" }, desc = "Increment" },
        { "<C-x>", "<Plug>(dial-decrement)", mode = { "n", "v" }, desc = "Decrement" },
        { "g<C-a>", "<Plug>(dial-g-increment)", mode = "v", desc = "Increment (cumulative)" },
        { "g<C-x>", "<Plug>(dial-g-decrement)", mode = "v", desc = "Decrement (cumulative)" },
    },
    config = function()
        local augend = require("dial.augend")
        local cyclic = function(elements, word)
            return augend.constant.new({ elements = elements, word = word or false, cyclic = true })
        end
        local bool = cyclic({ "true", "false" }, true)
        local logical = cyclic({ "&&", "||" })
        local eq = cyclic({ "==", "!=" })

        -- Shared base; per-filetype lists extend it (TS keeps numbers/dates too).
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
        local ts = vim.list_extend({ cyclic({ "let", "const" }, true) }, common)
        local markdown = vim.list_extend({ augend.misc.alias.markdown_header }, common)

        -- on_filetype (NOT register_group): the <Plug> maps read config.augends.filetype[ft]; `_` = fallback.
        require("dial.config").augends:on_filetype({
            typescript = ts,
            typescriptreact = ts,
            javascript = ts,
            javascriptreact = ts,
            markdown = markdown,
            _ = common,
        })
    end,
}
