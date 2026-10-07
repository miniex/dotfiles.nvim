vim.filetype.add({ extension = { typ = "typst" } })

return {
    require("config.lang").treesitter({ "typst" }),
}
