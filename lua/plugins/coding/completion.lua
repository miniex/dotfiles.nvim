return {
    {
        "hrsh7th/nvim-cmp",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*",
                build = "make install_jsregexp",
                dependencies = { "rafamadriz/friendly-snippets" },
            },
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        opts = function()
            local cmp = require("cmp")
            return {
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<C-S-f>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.close(),
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    }),
                }),
                sources = cmp.config.sources({
                    { name = "path" },
                    { name = "nvim_lsp", keyword_length = 3 },
                    { name = "nvim_lsp_signature_help" },
                    { name = "luasnip", keyword_length = 2 },
                    { name = "buffer", keyword_length = 2 },
                }),
                formatting = {
                    fields = { "menu", "abbr", "kind" },
                    format = function(entry, item)
                        local menu_icon = {
                            nvim_lsp = "λ",
                            luasnip = "⋗",
                            buffer = "Ω",
                            path = "🖫",
                        }
                        item.menu = menu_icon[entry.source.name]
                        return item
                    end,
                },
            }
        end,
        config = function(_, opts)
            require("luasnip.loaders.from_vscode").lazy_load()
            require("cmp").setup(opts)
        end,
    },
}
