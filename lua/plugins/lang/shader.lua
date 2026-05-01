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

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "wgsl", "glsl", "hlsl" })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                wgsl_analyzer = {},
                glsl_analyzer = {},
            },
        },
    },
}
