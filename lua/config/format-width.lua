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

-- Per-filetype { sources, default } for M.guide. A string value aliases another
-- filetype's spec (e.g. cpp → c).
M.specs = {
    c = {
        sources = {
            { names = { ".clang-format", "_clang-format" }, pattern = "^%s*ColumnLimit%s*:%s*(%d+)" },
        },
        default = 80,
    },
    cpp = "c",
    elixir = {
        sources = {
            { names = { ".formatter.exs" }, pattern = "line_length%s*:%s*(%d+)" },
        },
        default = 98,
    },
    lua = {
        sources = {
            { names = { "stylua.toml", ".stylua.toml" }, pattern = "^%s*column_width%s*=%s*(%d+)" },
        },
        default = 120,
    },
    ocaml = {
        sources = {
            { names = { ".ocamlformat" }, pattern = "^%s*margin%s*=%s*(%d+)" },
        },
        default = 80,
    },
    python = {
        sources = {
            { names = { "ruff.toml", ".ruff.toml" }, pattern = "^%s*line%-length%s*=%s*(%d+)" },
            { names = { "pyproject.toml" }, pattern = "^%s*line%-length%s*=%s*(%d+)" },
        },
        default = 88,
    },
    rust = {
        sources = {
            { names = { "rustfmt.toml", ".rustfmt.toml" }, pattern = "^%s*max_width%s*=%s*(%d+)" },
        },
        default = 100,
    },
    sql = {
        sources = {
            { names = { ".sqlfluff" }, pattern = "^%s*max_line_length%s*=%s*(%d+)" },
            { names = { "pyproject.toml" }, pattern = "^%s*max_line_length%s*=%s*(%d+)" },
        },
        default = 80,
    },
    toml = {
        sources = {
            { names = { "taplo.toml", ".taplo.toml" }, pattern = "^%s*column_width%s*=%s*(%d+)" },
        },
        default = 80,
    },
}

-- Resolve `ft`'s spec (following one alias hop) and apply its guide.
function M.apply(ft)
    local spec = M.specs[ft]
    if type(spec) == "string" then
        spec = M.specs[spec]
    end
    if spec then
        return M.guide(spec.sources, spec.default)
    end
end

-- One FileType autocmd for all registered fts (replaces the per-ft stubs).
local group = vim.api.nvim_create_augroup("format-width", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = vim.tbl_keys(M.specs),
    callback = function(args)
        M.apply(vim.bo[args.buf].filetype)
    end,
})

-- Derive the cache-clear filenames from M.specs so they can't drift.
local config_names = {}
do
    local seen = {}
    for _, spec in pairs(M.specs) do
        if type(spec) == "table" then
            for _, src in ipairs(spec.sources) do
                for _, n in ipairs(src.names) do
                    if not seen[n] then
                        seen[n] = true
                        config_names[#config_names + 1] = n
                    end
                end
            end
        end
    end
end

-- Drop the cache when a formatter config is saved so the ruler re-scans.
vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = config_names,
    callback = function()
        cache = {}
    end,
})

return M
