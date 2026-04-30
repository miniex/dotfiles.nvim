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
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                marksman = {
                    filetypes = { "markdown", "mdx" },
                },
                mdx_analyzer = {},
            },
        },
    },
}
