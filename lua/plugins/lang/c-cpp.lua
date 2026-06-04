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
    require("config.dap").spec(function(dap)
        dap.adapters.codelldb = dap.adapters.codelldb or require("config.codelldb").adapter("c/c++")
        if not dap.adapters.codelldb then
            return
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
    end),
}
