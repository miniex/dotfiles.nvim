vim.filetype.add({
    pattern = {
        [".*/templates/.*%.tpl"] = "helm",
        [".*/templates/.*%.ya?ml"] = "helm",
        ["helmfile.*%.ya?ml"] = "helm",
    },
})

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "helm" })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                helm_ls = {
                    filetypes = { "helm" },
                    settings = {
                        ["helm-ls"] = {
                            yamlls = {
                                path = "yaml-language-server",
                            },
                        },
                    },
                },
                -- yamlls is invalid for helm templates because of go-template
                -- syntax injection. Disable yamlls for helm filetype to keep
                -- diagnostics clean.
                yamlls = {
                    filetypes = { "yaml" },
                },
            },
        },
    },
}
