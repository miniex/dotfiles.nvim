local dap = require("config.dap")

return {
    dap.spec(function(d)
        local cmd = dap.mason_bin("bin/bash-debug-adapter", "bash-debug-adapter")
        if not cmd then
            return
        end
        local ext = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension"
        d.adapters.bashdb = { type = "executable", command = cmd, name = "bashdb" }
        local cfg = {
            {
                type = "bashdb",
                request = "launch",
                name = "Launch (bashdb)",
                program = "${file}",
                cwd = "${workspaceFolder}",
                pathBashdb = ext .. "/bashdb_dir/bashdb",
                pathBashdbLib = ext .. "/bashdb_dir",
                pathBash = "bash",
                pathCat = "cat",
                pathMkfifo = "mkfifo",
                pathPkill = "pkill",
                args = {},
                env = {},
                terminalKind = "integrated",
            },
        }
        d.configurations.sh = cfg
        d.configurations.bash = cfg
    end),
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "bash-debug-adapter" })
        end,
    },
}
