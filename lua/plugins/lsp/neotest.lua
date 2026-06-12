-- Neotest: unified runner. Rust adapter via rustaceanvim.neotest.
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
            "MisanthropicBit/neotest-busted",
            "lawrence-laz/neotest-zig",
            "marilari88/neotest-vitest",
            "nvim-neotest/neotest-jest",
            "olimorris/neotest-phpunit",
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

            local adapters = {
                require("neotest-python")({
                    runner = "pytest",
                    dap = { justMyCode = false },
                }),
                require("neotest-golang")({
                    dap_go_enabled = true,
                }),
                require("neotest-elixir"),
                require("neotest-gtest").setup({}),
                require("neotest-busted"),
                require("neotest-zig")({}),
                require("neotest-vitest"),
                require("neotest-jest"),
                require("neotest-phpunit"),
            }
            -- Force-load rustaceanvim's rust adapter so rust tests are always present (neotest is
            -- keys-lazy, so not a startup cost; a later re-setup would rebuild the client mid-run).
            local ok_rust, rust = pcall(require, "rustaceanvim.neotest")
            if ok_rust then
                table.insert(adapters, rust)
            end

            require("neotest").setup({
                adapters = adapters,
                -- Single discovery worker: caps the CPU spike when scanning tests on big repos.
                discovery = { concurrent = 1 },
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
                floating = { border = vim.g.flower_border },
            })

            -- Restore summary window across sessions. mksession only saves
            -- UPPERCASE globals, hence NEOTEST_SUMMARY_OPEN.
            local session_group = vim.api.nvim_create_augroup("neotest-session", { clear = true })
            vim.api.nvim_create_autocmd("VimLeavePre", {
                group = session_group,
                callback = function()
                    local open = false
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.bo[buf].filetype == "neotest-summary" then
                            open = true
                            break
                        end
                    end
                    vim.g.NEOTEST_SUMMARY_OPEN = open and 1 or nil
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "PersistenceLoadPost",
                group = session_group,
                callback = function()
                    if vim.g.NEOTEST_SUMMARY_OPEN == 1 then
                        vim.schedule(function()
                            pcall(function()
                                require("neotest").summary.open()
                            end)
                        end)
                    end
                end,
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            -- gotestsum: optional, improves neotest-golang parsing speed.
            vim.list_extend(opts.ensure_installed, { "gotestsum" })
        end,
    },
}
