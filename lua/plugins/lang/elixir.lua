return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "elixir", "heex", "eex" })
        end,
    },
    {
        "mfussenegger/nvim-dap",
        optional = true,
        config = function()
            local dap = require("dap")
            local adapter = vim.fn.stdpath("data") .. "/mason/packages/elixir-ls/debug_adapter.sh"
            if vim.fn.executable(adapter) ~= 1 then
                vim.schedule(function()
                    vim.notify(
                        "elixir-ls debug adapter not found at " .. adapter .. "\nRun :MasonInstall elixir-ls",
                        vim.log.levels.WARN,
                        { title = "nvim-dap (elixir)" }
                    )
                end)
                return
            end

            dap.adapters.mix_task = {
                type = "executable",
                command = adapter,
                args = {},
            }

            dap.configurations.elixir = {
                {
                    name = "mix test",
                    type = "mix_task",
                    request = "launch",
                    task = "test",
                    taskArgs = { "--trace" },
                    startApps = true,
                    projectDir = "${workspaceFolder}",
                    requireFiles = {
                        "test/**/test_helper.exs",
                        "test/**/*_test.exs",
                    },
                },
                {
                    name = "mix run",
                    type = "mix_task",
                    request = "launch",
                    task = "run",
                    projectDir = "${workspaceFolder}",
                },
            }
        end,
    },
}
