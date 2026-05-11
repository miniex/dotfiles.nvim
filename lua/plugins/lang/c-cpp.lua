return {
    {
        "p00f/clangd_extensions.nvim",
        ft = { "c", "cpp" },
        keys = {
            {
                "<leader>ch",
                "<cmd>ClangdSwitchSourceHeader<cr>",
                desc = "Switch Source/Header (C/C++)",
                ft = { "c", "cpp" },
            },
        },
        opts = {
            inlay_hints = {
                inline = false,
            },
            ast = {
                role_icons = {
                    type = "",
                    declaration = "",
                    expression = "",
                    specifier = "",
                    statement = "",
                    ["template argument"] = "",
                },
                kind_icons = {
                    Compound = "",
                    Recovery = "",
                    TranslationUnit = "",
                    PackExpansion = "",
                    TemplateTypeParm = "",
                    TemplateTemplateParm = "",
                    TemplateParamObject = "",
                },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                clangd = {
                    root_dir = function(bufnr, on_dir)
                        local fname = vim.api.nvim_buf_get_name(bufnr)
                        local primary = vim.fs.root(fname, {
                            "Makefile",
                            "configure.ac",
                            "configure.in",
                            "config.h.in",
                            "meson.build",
                            "meson_options.txt",
                            "build.ninja",
                        })
                        local secondary = vim.fs.root(fname, {
                            "compile_commands.json",
                            "compile_flags.txt",
                        })
                        local fallback = vim.fs.root(fname, ".git")
                        on_dir(primary or secondary or fallback)
                    end,
                    capabilities = {
                        offsetEncoding = { "utf-16" },
                    },
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                },
            },
        },
    },
}
