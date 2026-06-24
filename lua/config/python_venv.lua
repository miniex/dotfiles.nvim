-- Resolve the project's Python interpreter so basedpyright resolves local-venv
-- imports. Auto-detected per LSP root; :VenvSelect overrides it, keyed by root.
local M = {}

local uv = vim.uv or vim.loop
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

M._overrides = {} -- root → interpreter chosen via :VenvSelect

-- Pick the interpreter for a root: session override → active env → project venv.
function M.detect(root)
    root = root or uv.cwd()
    if M._overrides[root] then
        return M._overrides[root]
    end
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

-- Interpreters to offer in the picker: project venvs + common global homes.
function M.candidates(root)
    root = root or vim.fs.root(0, { ".git", "pyproject.toml", "setup.py" }) or uv.cwd()
    local out, seen = {}, {}
    local function add(py)
        if py and not seen[py] then
            seen[py] = true
            out[#out + 1] = py
        end
    end
    for _, name in ipairs({ ".venv", "venv", "env", ".env" }) do
        add(interpreter(root .. "/" .. name))
    end
    add(interpreter(vim.env.VIRTUAL_ENV))
    add(interpreter(vim.env.CONDA_PREFIX))
    for _, home in ipairs({ "~/.virtualenvs", "~/.pyenv/versions" }) do
        for _, dir in ipairs(vim.fn.glob(vim.fn.expand(home) .. "/*", true, true)) do
            add(interpreter(dir))
        end
    end
    return out
end

-- Apply to live basedpyright clients (re-reads pythonPath on didChangeConfiguration, no restart).
local function apply(clients, py)
    for _, client in ipairs(clients) do
        client.settings = vim.tbl_deep_extend("force", client.settings or {}, { python = { pythonPath = py } })
        client:notify("workspace/didChangeConfiguration", { settings = client.settings })
    end
end

-- :VenvSelect — choose the interpreter via vim.ui.select (snacks-routed).
function M.select()
    local clients = vim.lsp.get_clients({ name = "basedpyright" })
    local root = (clients[1] and clients[1].root_dir) or uv.cwd()
    local cands = M.candidates(root)
    if vim.tbl_isempty(cands) then
        vim.notify("No Python virtualenvs found", vim.log.levels.WARN, { title = "venv" })
        return
    end
    vim.ui.select(cands, { prompt = "Python interpreter:" }, function(choice)
        if not choice then
            return
        end
        M._overrides[root] = choice
        apply(clients, choice)
        vim.notify("Python: " .. choice, vim.log.levels.INFO, { title = "venv" })
    end)
end

return M
