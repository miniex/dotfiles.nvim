local map_key = require("utils.key_mapper").map_key

return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = {
            ensure_installed = {
                "clangd",
                "neocmake",
                "vtsls",
                "jsonls",
                "lua-language-server",
                "marksman",
                "pyright",
                "ruff",
                "rust-analyzer",
                "tailwindcss-language-server",
                "codelldb",
                "debugpy",
            },
        },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        opts = {
            ensure_installed = {
                "clangd",
                "neocmake",
                "vtsls",
                "jsonls",
                "lua_ls",
                "marksman",
                "pyright",
                "ruff",
                "tailwindcss",
            },
            automatic_installation = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason.nvim",
            "mason-lspconfig.nvim",
        },
        opts = {
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                },
                severity_sort = true,
            },
            inlay_hints = {
                enabled = true,
            },
            codelens = {
                enabled = false,
            },
            document_highlight = {
                enabled = true,
            },
            capabilities = {},
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            servers = {},
            setup = {},
        },
        config = function(_, opts)
            -- Global mappings
            map_key("K", vim.lsp.buf.hover)
            map_key("gd", vim.lsp.buf.definition)
            map_key("<leader>cc", vim.diagnostic.open_float)
            map_key("<leader>ca", vim.lsp.buf.code_action)
            map_key("gr", vim.lsp.buf.references)
            map_key("gi", vim.lsp.buf.implementation)
            map_key("<leader>rn", vim.lsp.buf.rename)

            -- Global handlers
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover, {
                    border = "rounded",
                }
            )

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                vim.lsp.handlers.signature_help, {
                    border = "rounded",
                }
            )

            local servers = opts.servers
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                has_cmp and cmp_nvim_lsp.default_capabilities() or {},
                opts.capabilities or {}
            )

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities),
                }, servers[server] or {})

                if opts.setup[server] then
                    if opts.setup[server](server, server_opts) then
                        return
                    end
                elseif opts.setup["*"] then
                    if opts.setup["*"](server, server_opts) then
                        return
                    end
                end
                require("lspconfig")[server].setup(server_opts)
            end

            local have_mason, mlsp = pcall(require, "mason-lspconfig")
            local all_mslp_servers = {}
            if have_mason then
                all_mslp_servers = mlsp.get_available_servers()
            end

            local ensure_installed = {}
            for server, server_opts in pairs(servers) do
                if server_opts then
                    server_opts = server_opts == true and {} or server_opts
                    if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
                        setup(server)
                    else
                        ensure_installed[#ensure_installed + 1] = server
                    end
                end
            end

            if have_mason then
                mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
            end
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufWritePre", "BufNewFile" },
        config = function()
            local conform = require("conform")

            conform.setup({
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            })
        end,
        cmd = "ConformInfo"
    }
}

