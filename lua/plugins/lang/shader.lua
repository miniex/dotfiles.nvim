-- Stock nvim already knows wgsl and the glsl stage extensions.
vim.filetype.add({
    extension = {
        vs = "glsl",
        fs = "glsl", -- stock: fsharp
        hlsl = "hlsl",
        fx = "hlsl",
        fxh = "hlsl",
        metal = "metal",
    },
})

return {
    require("config.lang").treesitter({ "wgsl", "glsl", "hlsl" }),
}
