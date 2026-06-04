return {
    -- Grammar (zig) lives in the base treesitter list.
    require("config.dap").spec(function(dap)
        dap.adapters.codelldb = dap.adapters.codelldb or require("config.codelldb").adapter("zig")
        if not dap.adapters.codelldb then
            return
        end

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
    end),
}
