local ts_fts = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

-- Browser DAP target from $PATH: Chrome/Chromium first, else Firefox, else none.
local function detect_browser()
    for _, bin in ipairs({ "google-chrome", "google-chrome-stable", "chromium", "chromium-browser" }) do
        if vim.fn.executable(bin) == 1 then
            return "chrome"
        end
    end
    for _, bin in ipairs({ "firefox", "firefox-developer-edition", "firefox-esr" }) do
        if vim.fn.executable(bin) == 1 then
            return "firefox"
        end
    end
    return nil
end
local browser = detect_browser()

-- js-debug covers Node (+ Chrome); add firefox-debug-adapter only for Firefox.
local dap_tools = { "js-debug-adapter" }
if browser == "firefox" then
    table.insert(dap_tools, "firefox-debug-adapter")
end

return {
    -- JS/TS code actions (source.* kinds are LSP-standard, no VtslsExec needed).
    require("config.lang").code_action_keys("TS", { "I", "U" }, ts_fts),
    -- JS/TS debugging: Node always; browser picked by detect_browser().
    require("config.dap").spec(function(dap)
        local resolve = require("config.dap").mason_bin
        local node = resolve("bin/js-debug-adapter", "js-debug-adapter")
        if node then
            -- One js-debug server backs both Node and Chrome.
            local jsdebug = {
                type = "server",
                host = "127.0.0.1",
                port = "${port}",
                executable = { command = node, args = { "${port}" } },
            }
            dap.adapters["pwa-node"] = jsdebug
            dap.adapters["pwa-chrome"] = jsdebug
        end
        local ff = browser == "firefox" and resolve("bin/firefox-debug-adapter", "firefox-debug-adapter")
        if ff then
            dap.adapters.firefox = { type = "executable", command = ff, args = {} }
        end
        for _, lang in ipairs(ts_fts) do
            local configs = {}
            if node then
                vim.list_extend(configs, {
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
                })
                if browser == "chrome" then
                    vim.list_extend(configs, {
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
                    })
                end
            end
            if ff then
                vim.list_extend(configs, {
                    {
                        type = "firefox",
                        request = "launch",
                        name = "Launch Firefox against dev server",
                        reAttach = true,
                        url = function()
                            return vim.fn.input("Dev server URL: ", "http://localhost:3000")
                        end,
                        webRoot = "${workspaceFolder}",
                    },
                    {
                        -- Firefox must run with `--start-debugger-server` (default port 6000).
                        type = "firefox",
                        request = "attach",
                        name = "Attach to Firefox (remote debugging)",
                        url = "http://localhost:3000",
                        webRoot = "${workspaceFolder}",
                    },
                })
            end
            dap.configurations[lang] = configs
        end
    end),
    require("config.lang").mason(dap_tools),
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
