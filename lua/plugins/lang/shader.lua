vim.filetype.add({
    extension = {
        wgsl = "wgsl",
        vert = "glsl",
        frag = "glsl",
        geom = "glsl",
        tesc = "glsl",
        tese = "glsl",
        comp = "glsl",
        rgen = "glsl",
        rmiss = "glsl",
        rchit = "glsl",
        rahit = "glsl",
        rint = "glsl",
        rcall = "glsl",
        glsl = "glsl",
        vs = "glsl",
        fs = "glsl",
        hlsl = "hlsl",
        fx = "hlsl",
        fxh = "hlsl",
        metal = "metal",
    },
})

-- Grammars (wgsl, glsl, hlsl) live in the base treesitter list.
return {}
