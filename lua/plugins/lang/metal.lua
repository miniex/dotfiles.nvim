-- Metal Shading Language: syntax highlighting via treesitter cpp parser + clang-format
vim.filetype.add({
    extension = {
        metal = "metal",
    },
})

vim.treesitter.language.register("cpp", "metal")

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("metal-syntax", { clear = true }),
    pattern = "metal",
    callback = function(args)
        vim.treesitter.start(args.buf, "cpp")
    end,
})

return {}
