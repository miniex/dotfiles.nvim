return {
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = { ensure_installed = { "rust-analyzer" } },
    },
    {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
            completion = {
                crates = {
                    enabled = true,
                },
            },
            lsp = {
                enabled = true,
                actions = true,
                completion = true,
                hover = true,
            },
        },
    },
    {
        "mrcjkb/rustaceanvim",
        ft = { "rust" },
        keys = {
            {
                "<leader>cR",
                function()
                    vim.cmd.RustLsp("codeAction")
                end,
                desc = "Rust Code Action",
                ft = "rust",
            },
            {
                "<leader>cD",
                function()
                    vim.cmd.RustLsp("debuggables")
                end,
                desc = "Rust Debuggables",
                ft = "rust",
            },
        },
        opts = {
            server = {
                on_attach = function(client, _)
                    client.server_capabilities.didChangeWatchedFilesDynamicRegistration = true
                end,
                default_settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = false,
                            loadOutDirsFromCheck = true,
                            buildScripts = {
                                enable = true,
                            },
                        },
                        checkOnSave = true,
                        diagnostics = {
                            disabled = { "inactive-code" },
                        },
                        procMacro = {
                            enable = true,
                        },
                        files = {
                            watcher = "client",
                            excludeDirs = {
                                ".direnv",
                                ".git",
                                ".github",
                                ".gitlab",
                                "bin",
                                "node_modules",
                                "target",
                                "venv",
                                ".venv",
                            },
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            local mason_ok, mason_registry = pcall(require, "mason-registry")
            if mason_ok and mason_registry.is_installed("codelldb") then
                local package_path = vim.fn.expand("$MASON/packages/codelldb")
                local codelldb = package_path .. "/extension/adapter/codelldb"
                local lib_ext = vim.uv.os_uname().sysname == "Darwin" and "dylib" or "so"
                local library_path = package_path .. "/extension/lldb/lib/liblldb." .. lib_ext
                opts.dap = {
                    adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
                }
            end
            vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
        end,
    },
}
