-- Metal Shading Language: syntax highlighting via treesitter cpp parser + clang-format
vim.filetype.add({
    extension = {
        metal = "metal",
    },
})

vim.treesitter.language.register("cpp", "metal")

return {}
