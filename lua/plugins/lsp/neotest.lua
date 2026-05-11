-- Neotest: unified test runner UI.
-- Adapters are loaded only when neotest itself loads (via <leader>t* keys).
-- Rust tests are handled by rustaceanvim's :RustLsp testables, so no adapter
-- is registered here for it.
return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
            "fredrikaverpil/neotest-golang",
            "jfpedroza/neotest-elixir",
            "alfaix/neotest-gtest",
        },
        keys = {
            {
                "<leader>nr",
                function()
                    require("neotest").run.run()
                end,
                desc = "Run nearest test",
            },
            {
                "<leader>nf",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Run file tests",
            },
            {
                "<leader>nA",
                function()
                    require("neotest").run.run(vim.uv.cwd())
                end,
                desc = "Run all tests",
            },
            {
                "<leader>nl",
                function()
                    require("neotest").run.run_last()
                end,
                desc = "Run last test",
            },
            {
                "<leader>nd",
                function()
                    require("neotest").run.run({ strategy = "dap" })
                end,
                desc = "Debug nearest test",
            },
            {
                "<leader>nx",
                function()
                    require("neotest").run.stop()
                end,
                desc = "Stop test",
            },
            {
                "<leader>ns",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Toggle summary",
            },
            {
                "<leader>no",
                function()
                    require("neotest").output.open({ enter = true, auto_close = true })
                end,
                desc = "Show output",
            },
            {
                "<leader>nO",
                function()
                    require("neotest").output_panel.toggle()
                end,
                desc = "Toggle output panel",
            },
            {
                "<leader>nw",
                function()
                    require("neotest").watch.toggle(vim.fn.expand("%"))
                end,
                desc = "Toggle watch (file)",
            },
            {
                "]T",
                function()
                    require("neotest").jump.next({ status = "failed" })
                end,
                desc = "Next failed test",
            },
            {
                "[T",
                function()
                    require("neotest").jump.prev({ status = "failed" })
                end,
                desc = "Prev failed test",
            },
        },
        config = function()
            -- Diagnostic icons; reuse the LSP severity glyphs from init.lua so
            -- the test status column reads consistently with diagnostics.
            local icons = {
                passed = " ",
                running = " ",
                failed = " ",
                unknown = " ",
                skipped = "󰒬 ",
            }
            local neotest_ns = vim.api.nvim_create_namespace("neotest")
            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " ")
                        return message
                    end,
                },
            }, neotest_ns)

            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        runner = "pytest",
                        dap = { justMyCode = false },
                    }),
                    require("neotest-golang")({
                        dap_go_enabled = true,
                    }),
                    require("neotest-elixir"),
                    require("neotest-gtest").setup({}),
                },
                status = { virtual_text = true },
                output = { open_on_run = false },
                quickfix = {
                    open = function()
                        require("trouble").open({ mode = "quickfix", focus = false })
                    end,
                },
                icons = icons,
                summary = {
                    animated = false,
                    mappings = {
                        expand = { "<Tab>", "zo" },
                        expand_all = "zR",
                    },
                },
                floating = { border = "rounded" },
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            -- Adapters either bundle their runners or expect project-local
            -- installs (pytest, mix). gotestsum is optional but improves
            -- neotest-golang's parsing speed.
            vim.list_extend(opts.ensure_installed, { "gotestsum" })
        end,
    },
}
