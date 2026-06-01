-- JS/TS code-action shortcuts. `source.*` kinds are LSP-standard (no VtslsExec needed).
local function code_action_only(kind)
    return function()
        vim.lsp.buf.code_action({
            context = { only = { kind }, diagnostics = {} },
            apply = true,
        })
    end
end

local ts_fts = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

return {
    {
        "neovim/nvim-lspconfig",
        keys = {
            {
                "<leader>cI",
                code_action_only("source.organizeImports"),
                desc = "TS: Organize Imports",
                ft = ts_fts,
            },
            {
                "<leader>cU",
                code_action_only("source.removeUnused"),
                desc = "TS: Remove Unused",
                ft = ts_fts,
            },
        },
    },
    -- Node debugging: js-debug-adapter as a DAP server (no extra plugin). Browser would need pwa-chrome.
    {
        "mfussenegger/nvim-dap",
        optional = true,
        opts = function(_, opts)
            opts.setups = opts.setups or {}
            table.insert(opts.setups, function(dap)
                local cmd = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter"
                if vim.fn.executable(cmd) ~= 1 then
                    vim.schedule(function()
                        vim.notify(
                            "js-debug-adapter not found — run :MasonInstall js-debug-adapter",
                            vim.log.levels.WARN,
                            { title = "JS/TS DAP" }
                        )
                    end)
                    return
                end
                dap.adapters["pwa-node"] = {
                    type = "server",
                    host = "127.0.0.1",
                    port = "${port}",
                    executable = {
                        command = cmd,
                        args = { "${port}" },
                    },
                }
                for _, lang in ipairs(ts_fts) do
                    dap.configurations[lang] = {
                        {
                            type = "pwa-node",
                            request = "launch",
                            name = "Launch file (Node)",
                            program = "${file}",
                            cwd = "${workspaceFolder}",
                        },
                        {
                            type = "pwa-node",
                            request = "attach",
                            name = "Attach to process",
                            processId = require("dap.utils").pick_process,
                            cwd = "${workspaceFolder}",
                        },
                    }
                end
            end)
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "js-debug-adapter" })
        end,
    },
}
