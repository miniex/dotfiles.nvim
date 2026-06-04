vim.filetype.add({ extension = { mdx = "mdx" } })

return {
    -- No dedicated mdx parser in nvim-treesitter; alias to markdown so
    -- prose/headings/code fences still highlight (JSX islands won't).
    require("config.lang").treesitter(nil, { markdown = "mdx" }),
}
