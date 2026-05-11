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
                    -- friendly-snippets ships VSCode JSON; user-authored
                    -- snippets live in ~/.config/nvim/snippets as Lua so they
                    -- can compute dynamic content (date, filename, etc.).
                    require("luasnip.loaders.from_vscode").lazy_load()
                    require("luasnip.loaders.from_lua").lazy_load({
                        paths = { vim.fn.stdpath("config") .. "/snippets" },
                    })
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
