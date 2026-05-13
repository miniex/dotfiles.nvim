vim.filetype.add({ extension = { mdx = "mdx" } })

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            -- No dedicated mdx parser in nvim-treesitter; alias to markdown so
            -- prose/headings/code fences still highlight (JSX islands won't).
            vim.treesitter.language.register("markdown", "mdx")
        end,
    },
    -- Inline render of headings/lists/checkboxes/tables/code. Raw in i/v.
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "mdx", "norg", "rmd", "org" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            file_types = { "markdown", "mdx" },
            render_modes = { "n", "c", "t" },
            anti_conceal = { enabled = true },
            heading = {
                sign = false,
                position = "inline",
                icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
            },
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
                border = "thin",
            },
            bullet = {
                icons = { "●", "○", "◆", "◇" },
            },
            checkbox = {
                unchecked = { icon = "󰄱 " },
                checked = { icon = "󰱒 " },
                custom = {
                    todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
                },
            },
            pipe_table = {
                style = "full",
                cell = "padded",
            },
            link = {
                wiki = { icon = "󱗖 ", highlight = "RenderMarkdownLink" },
            },
        },
        keys = {
            {
                "<leader>um",
                function()
                    require("render-markdown").toggle()
                end,
                desc = "Toggle markdown render",
            },
        },
    },
}
