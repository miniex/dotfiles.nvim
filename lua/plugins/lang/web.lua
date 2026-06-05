local ts_fts = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

return {
    -- JS/TS code actions (source.* kinds are LSP-standard, no VtslsExec needed).
    require("config.lang").code_action_keys("TS", { "I", "U" }, ts_fts),
    -- Node debugging: js-debug-adapter as a DAP server (no extra plugin). Browser would need pwa-chrome.
    require("config.dap").spec(function(dap)
        local cmd = require("config.dap").mason_bin("bin/js-debug-adapter", "js-debug-adapter")
        if not cmd then
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
    end),
    require("config.lang").mason({ "js-debug-adapter" }),
    -- package.json dependency versions inline (crates.nvim's JS analogue).
    {
        "vuki656/package-info.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        event = "BufRead package.json",
        opts = { autostart = true, hide_up_to_date = true },
        init = function()
            vim.api.nvim_create_autocmd("BufReadPost", {
                pattern = "package.json",
                group = vim.api.nvim_create_augroup("PackageInfoKeys", { clear = true }),
                callback = function(args)
                    local pi = require("package-info")
                    local function map(lhs, fn, desc)
                        vim.keymap.set("n", lhs, fn, { buffer = args.buf, silent = true, desc = desc })
                    end
                    map("<leader>cv", pi.show, "Package: versions")
                    map("<leader>cu", pi.update, "Package: update")
                    map("<leader>cU", pi.change_version, "Package: change version")
                    map("<leader>cD", pi.delete, "Package: delete")
                end,
            })
        end,
    },
}
