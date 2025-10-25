return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                pyright = {
                    enabled = true,
                },
                ruff = {
                    enabled = true,
                    cmd_env = { RUFF_TRACE = "messages" },
                    init_options = {
                        settings = {
                            logLevel = "error",
                        },
                    },
                    keys = {
                        {
                            "<leader>co",
                            function()
                                vim.lsp.buf.code_action({
                                    context = { only = { "source.organizeImports" } },
                                    apply = true,
                                })
                            end,
                            desc = "Organize Imports",
                        },
                    },
                },
            },
            setup = {
                ruff = function()
                    local function on_attach(client, _)
                        client.server_capabilities.hoverProvider = false
                    end
                    local lspconfig = require("lspconfig")
                    local orig_setup = lspconfig.ruff.setup
                    lspconfig.ruff.setup = function(config)
                        config.on_attach = on_attach
                        return orig_setup(config)
                    end
                end,
            },
        },
    },
    {
        "mfussenegger/nvim-dap-python",
        keys = {
            { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
            { "<leader>dPc", function() require('dap-python').test_class() end,  desc = "Debug Class",  ft = "python" },
        },
        config = function()
            require("dap-python").setup("python")
        end,
    },
}

