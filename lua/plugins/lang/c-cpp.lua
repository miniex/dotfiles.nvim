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
        "mfussenegger/nvim-dap",
        ft = { "c", "cpp" },
        config = function()
            local dap = require("dap")
            -- codelldb is installed by mason-tool-installer via dap.lua. We
            -- skip registration if it isn't on disk yet (first launch) — the
            -- adapter is re-resolved on each session start, so users only need
            -- to relaunch after the install completes.
            local mason_ok, mason_registry = pcall(require, "mason-registry")
            if mason_ok and mason_registry.is_installed("codelldb") then
                local pkg = vim.fn.expand("$MASON/packages/codelldb")
                dap.adapters.codelldb = {
                    type = "server",
                    port = "${port}",
                    executable = {
                        command = pkg .. "/extension/adapter/codelldb",
                        args = { "--port", "${port}" },
                    },
                }
            end

            local function pick_executable()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end

            local cpp_config = {
                {
                    name = "Launch (codelldb)",
                    type = "codelldb",
                    request = "launch",
                    program = pick_executable,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
                {
                    name = "Attach to PID (codelldb)",
                    type = "codelldb",
                    request = "attach",
                    pid = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                },
            }
            dap.configurations.c = cpp_config
            dap.configurations.cpp = cpp_config
        end,
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
