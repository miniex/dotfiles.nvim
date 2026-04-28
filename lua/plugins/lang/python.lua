return {
    {
        "williamboman/mason.nvim",
        opts = { ensure_installed = { "basedpyright", "ruff", "debugpy" } },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = { ensure_installed = { "basedpyright", "ruff" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                basedpyright = {
                    settings = {
                        basedpyright = {
                            analysis = {
                                typeCheckingMode = "standard",
                                autoImportCompletions = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "openFilesOnly",
                            },
                        },
                    },
                },
                ruff = {
                    init_options = {
                        settings = {
                            logLevel = "error",
                        },
                    },
                    -- Hover handled by basedpyright; ruff only for diagnostics + code actions
                    on_attach = function(client, _)
                        client.server_capabilities.hoverProvider = false
                    end,
                },
            },
        },
    },
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
            require("dap-python").setup(mason_path)
        end,
        keys = {
            {
                "<leader>dPt",
                function()
                    require("dap-python").test_method()
                end,
                desc = "Debug Python Test Method",
                ft = "python",
            },
            {
                "<leader>dPc",
                function()
                    require("dap-python").test_class()
                end,
                desc = "Debug Python Test Class",
                ft = "python",
            },
        },
    },
}
