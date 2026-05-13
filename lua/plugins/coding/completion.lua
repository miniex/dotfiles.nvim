return {
    {
        "saghen/blink.cmp",
        version = "v1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "rafamadriz/friendly-snippets",
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*",
                build = "make install_jsregexp",
                config = function()
                    -- VSCode JSON (friendly-snippets) + user Lua snippets (dynamic).
                    require("luasnip.loaders.from_vscode").lazy_load()
                    require("luasnip.loaders.from_lua").lazy_load({
                        paths = { vim.fn.stdpath("config") .. "/snippets" },
                    })

                    -- luasnip keys by exact filetype; extend to share across variants.
                    local ls = require("luasnip")
                    ls.filetype_extend("typescriptreact", { "typescript", "javascript" })
                    ls.filetype_extend("javascriptreact", { "javascript" })
                    ls.filetype_extend("typescript", { "javascript" })
                    ls.filetype_extend("bash", { "sh" })
                    ls.filetype_extend("zsh", { "sh" })
                end,
            },
        },
        ---@module "blink.cmp"
        ---@type blink.cmp.Config
        opts = {
            keymap = {
                preset = "none",
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<C-n>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
                ["<C-S-f>"] = { "scroll_documentation_up", "fallback" },
            },
            appearance = {
                nerd_font_variant = "mono",
            },
            completion = {
                accept = { auto_brackets = { enabled = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                menu = {
                    border = "rounded",
                    draw = {
                        columns = {
                            { "label", "label_description", gap = 1 },
                            { "kind_icon", "kind" },
                        },
                    },
                },
            },
            signature = { enabled = true, window = { border = "rounded" } },
            snippets = { preset = "luasnip" },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
        },
    },
}
