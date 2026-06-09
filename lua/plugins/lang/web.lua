local ts_fts = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

return {
    -- JS/TS code actions (source.* kinds are LSP-standard, no VtslsExec needed).
    require("config.lang").code_action_keys("TS", { "I", "U" }, ts_fts),
    -- JS/TS debugging via js-debug-adapter (DAP server, no extra plugin): Node + Chrome.
    require("config.dap").spec(function(dap)
        local cmd = require("config.dap").mason_bin("bin/js-debug-adapter", "js-debug-adapter")
        if not cmd then
            return
        end
        -- One js-debug server backs both Node (pwa-node) and the browser (pwa-chrome).
        local adapter = {
            type = "server",
            host = "127.0.0.1",
            port = "${port}",
            executable = {
                command = cmd,
                args = { "${port}" },
            },
        }
        dap.adapters["pwa-node"] = adapter
        dap.adapters["pwa-chrome"] = adapter
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
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch Chrome against dev server",
                    url = function()
                        return vim.fn.input("Dev server URL: ", "http://localhost:3000")
                    end,
                    webRoot = "${workspaceFolder}",
                },
                {
                    type = "pwa-chrome",
                    request = "attach",
                    name = "Attach to Chrome (--remote-debugging-port=9222)",
                    port = 9222,
                    webRoot = "${workspaceFolder}",
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
