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
            -- Skip codelldb if not installed yet; re-resolved on next session.
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
}
