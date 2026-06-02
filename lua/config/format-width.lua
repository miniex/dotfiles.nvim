-- colorcolumn guide that follows each project's formatter width (rustfmt.toml,
-- ruff, …) instead of a hardcoded default. Extend via a { names, pattern } source.
local M = {}

-- Nearest config among `names` upward from `dir`; first `pattern` capture as a
-- number, or nil. vim.fs.find's default limit = 1, so the nearest config wins.
-- Memoized per (dir, names, pattern); formatter config rarely changes mid-session.
-- false = scanned, nothing found (vs nil = not scanned yet).
local cache = {}

local function scan_up(names, pattern, dir)
    local key = dir .. "\0" .. table.concat(names, ",") .. "\0" .. pattern
    local cached = cache[key]
    if cached ~= nil then
        return cached or nil
    end
    local found
    for _, path in ipairs(vim.fs.find(names, { upward = true, path = dir, type = "file" })) do
        local ok, lines = pcall(vim.fn.readfile, path)
        if ok then
            for _, line in ipairs(lines) do
                local n = line:match(pattern)
                if n then
                    found = tonumber(n)
                    break
                end
            end
        end
        if found then
            break
        end
    end
    cache[key] = found or false
    return found
end

-- Set textwidth + colorcolumn (width + 1) from the first matching source, else
-- `default`. sources: { { names = {…}, pattern = "…(%d+)" }, … }, tried in order.
function M.guide(sources, default)
    local name = vim.api.nvim_buf_get_name(0)
    local dir = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
    local width = default
    for _, src in ipairs(sources) do
        local found = scan_up(src.names, src.pattern, dir)
        if found then
            width = found
            break
        end
    end
    -- 0 (e.g. clang-format ColumnLimit: 0 = unlimited) means no ruler.
    vim.opt_local.textwidth = width
    vim.opt_local.colorcolumn = width > 0 and tostring(width + 1) or ""
    return width
end

return M
