-- Shared nvim-dap helpers for lang specs.
local M = {}

-- Append a setup fn to the dap opts.setups list (run by the base dap spec).
function M.setup(opts, fn)
    opts.setups = opts.setups or {}
    table.insert(opts.setups, fn)
end

-- Resolve a Mason binary under the data dir; returns the path, or nil with a
-- one-shot warning (label is the :MasonInstall package name).
function M.mason_bin(rel, label)
    local path = vim.fn.stdpath("data") .. "/mason/" .. rel
    if vim.fn.executable(path) ~= 1 then
        vim.schedule(function()
            vim.notify(
                label .. " not found at " .. path .. "\nRun :MasonInstall " .. label,
                vim.log.levels.WARN,
                { title = "nvim-dap" }
            )
        end)
        return nil
    end
    return path
end

return M
