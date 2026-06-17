-- Shared codelldb paths (Mason binary + liblldb), resolved directly to bypass
-- Mason's bash wrapper. Used by C/C++/Zig/Nim DAP adapters + lang/rust.lua.
local M = {}

local pkg = vim.fn.stdpath("data") .. "/mason/packages/codelldb"
M.binary = pkg .. "/extension/adapter/codelldb"
M.library = pkg .. "/extension/lldb/lib/liblldb." .. (vim.uv.os_uname().sysname == "Darwin" and "dylib" or "so")

-- Returns a dap.adapters.codelldb spec, or nil (with a warning) if not installed.
local warned = false
function M.adapter(lang)
    if vim.fn.executable(M.binary) ~= 1 then
        -- Warn once: several langs call this, else duplicate toasts.
        if not warned then
            warned = true
            vim.schedule(function()
                vim.notify(
                    "codelldb not found at " .. M.binary .. "\nRun :MasonInstall codelldb",
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
        executable = { command = M.binary, args = { "--port", "${port}" } },
    }
end

return M
