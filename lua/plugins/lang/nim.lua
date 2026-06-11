-- Grammar (nim) in the base treesitter list; nim_langserver via lang_servers.
-- No Nim-specific DAP adapter exists; debug compiled binaries with codelldb.
return {
    require("config.dap").spec(function(dap)
        dap.adapters.codelldb = dap.adapters.codelldb or require("config.codelldb").adapter("nim")
        if not dap.adapters.codelldb then
            return
        end

        dap.configurations.nim = {
            {
                name = "Launch (codelldb)",
                type = "codelldb",
                request = "launch",
                program = function()
                    -- Nim has no standard output dir; default to the project-name binary in cwd.
                    local cwd = vim.fn.getcwd()
                    local default = cwd .. "/" .. vim.fn.fnamemodify(cwd, ":t")
                    return vim.fn.input("Executable: ", default, "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                args = {},
            },
        }
    end),
}
