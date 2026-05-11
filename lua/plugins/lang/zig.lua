return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "zig" })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                zls = {
                    settings = {
                        zls = {
                            enable_inlay_hints = true,
                            inlay_hints_show_builtin = true,
                            inlay_hints_exclude_single_argument = true,
                            inlay_hints_hide_redundant_param_names = true,
                            inlay_hints_hide_redundant_param_names_last_token = true,
                            warn_style = true,
                            highlight_global_var_declarations = true,
                            enable_autofix = false,
                            enable_snippets = true,
                            enable_argument_placeholders = true,
                            enable_build_on_save = true,
                            semantic_tokens = "full",
                        },
                    },
                },
            },
        },
    },
}
