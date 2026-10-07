return {
    require("config.lang").treesitter({ "elixir", "heex", "eex" }),
    require("config.dap").spec(function(dap)
        local adapter = require("config.dap").mason_bin("packages/elixir-ls/debug_adapter.sh", "elixir-ls")
        if not adapter then
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
    end),
    require("config.lang").neotest("jfpedroza/neotest-elixir", function()
        return require("neotest-elixir")
    end),
}
