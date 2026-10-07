-- Resolve the project's Python interpreter so basedpyright resolves local-venv
-- imports. To switch at runtime use lspconfig's :LspPyrightSetPythonPath.
local M = {}

local uv = vim.uv
local is_win = (uv.os_uname().sysname or ""):find("Windows") ~= nil
local bindir = is_win and "Scripts" or "bin"
local exe = is_win and "python.exe" or "python"

-- A venv directory → its interpreter path, or nil if absent.
local function interpreter(venv)
    if not venv or venv == "" then
        return nil
    end
    local p = table.concat({ venv, bindir, exe }, "/")
    return uv.fs_stat(p) and p or nil
end

-- Pick the interpreter for a root: active env → project venv.
function M.detect(root)
    root = root or uv.cwd()
    local active = interpreter(vim.env.VIRTUAL_ENV) or interpreter(vim.env.CONDA_PREFIX)
    if active then
        return active
    end
    for _, name in ipairs({ ".venv", "venv", "env", ".env" }) do
        local p = interpreter(root .. "/" .. name)
        if p then
            return p
        end
    end
    return nil
end

return M
