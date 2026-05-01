return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "ocaml", "ocaml_interface" })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                ocamllsp = {
                    filetypes = {
                        "ocaml",
                        "ocaml.menhir",
                        "ocaml.interface",
                        "ocaml.ocamllex",
                        "reason",
                        "dune",
                    },
                },
            },
        },
    },
}
