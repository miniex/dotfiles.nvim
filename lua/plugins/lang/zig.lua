return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "zig" })
        end,
    },
    {
        "mfussenegger/nvim-dap",
        optional = true,
        config = function()
            local dap = require("dap")
            -- Same path rustaceanvim uses; bypasses Mason's bash wrapper.
            local codelldb = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
            if vim.fn.executable(codelldb) ~= 1 then
                vim.schedule(function()
                    vim.notify(
                        "codelldb not found at " .. codelldb .. "\nRun :MasonInstall codelldb",
                        vim.log.levels.WARN,
                        { title = "nvim-dap (zig)" }
                    )
                end)
                return
            end

            dap.adapters.codelldb = dap.adapters.codelldb
                or {
                    type = "server",
                    port = "${port}",
                    executable = { command = codelldb, args = { "--port", "${port}" } },
                }

            dap.configurations.zig = {
                {
                    name = "Launch (codelldb)",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        local cwd = vim.fn.getcwd()
                        local default = cwd .. "/zig-out/bin/" .. vim.fn.fnamemodify(cwd, ":t")
                        return vim.fn.input("Executable: ", default, "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
            }
        end,
    },
}
