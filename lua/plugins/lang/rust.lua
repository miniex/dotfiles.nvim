return {
    require("config.lang").mason({ "rust-analyzer" }),
    {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        -- Buffer-local keymaps only in Cargo.toml (crates doesn't attach to other toml).
        init = function()
            vim.api.nvim_create_autocmd("BufReadPost", {
                pattern = "Cargo.toml",
                group = vim.api.nvim_create_augroup("CratesKeys", { clear = true }),
                callback = function(args)
                    local crates = require("crates")
                    local function map(lhs, fn, desc)
                        vim.keymap.set("n", lhs, fn, { buffer = args.buf, silent = true, desc = desc })
                    end
                    map("<leader>cv", crates.show_versions_popup, "Crates: Versions")
                    map("<leader>cF", crates.show_features_popup, "Crates: Features")
                    map("<leader>cu", crates.update_crate, "Crates: Update")
                    map("<leader>cU", crates.upgrade_crate, "Crates: Upgrade")
                    map("<leader>cD", crates.open_documentation, "Crates: Docs")
                end,
            })
        end,
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
            {
                "<leader>cT",
                function()
                    vim.cmd.RustLsp("testables")
                end,
                desc = "Rust Testables",
                ft = "rust",
            },
            {
                "<leader>cE",
                function()
                    vim.cmd.RustLsp("expandMacro")
                end,
                desc = "Rust Expand Macro",
                ft = "rust",
            },
            {
                "<leader>cP",
                function()
                    vim.cmd.RustLsp("parentModule")
                end,
                desc = "Rust Parent Module",
                ft = "rust",
            },
        },
        opts = {
            server = {
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
                        inlayHints = {
                            bindingModeHints = { enable = false },
                            chainingHints = { enable = false },
                            closingBraceHints = { enable = true, minLines = 25 },
                            closureReturnTypeHints = { enable = "never" },
                            lifetimeElisionHints = { enable = "never" },
                            parameterHints = { enable = true },
                            typeHints = { enable = true },
                        },
                        lens = {
                            enable = true,
                            run = { enable = true },
                            debug = { enable = true },
                            implementations = { enable = true },
                            references = {
                                adt = { enable = false },
                                enumVariant = { enable = false },
                                method = { enable = false },
                                trait = { enable = false },
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
