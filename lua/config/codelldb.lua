-- Shared codelldb DAP adapter resolution (C/C++, Zig). Resolves the Mason
-- binary directly, bypassing Mason's bash wrapper (same path rustaceanvim uses).
local M = {}

-- Returns a dap.adapters.codelldb spec, or nil (with a warning) if not installed.
local warned = false
function M.adapter(lang)
    local path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
    if vim.fn.executable(path) ~= 1 then
        -- Warn once: C/C++ and Zig both call this, else two identical toasts.
        if not warned then
            warned = true
            vim.schedule(function()
                vim.notify(
                    "codelldb not found at " .. path .. "\nRun :MasonInstall codelldb",
                    vim.log.levels.WARN,
                    { title = "nvim-dap (" .. lang .. ")" }
                )
            end)
        end
        return nil
    end
    return {
        type = "server",
        port = "${port}",
        executable = { command = path, args = { "--port", "${port}" } },
    }
end

return M
