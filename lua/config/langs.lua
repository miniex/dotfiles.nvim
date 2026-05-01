-- Per-user language toggle. To disable some languages without diverging
-- from upstream, create `lua/config/langs_local.lua` (gitignored) and return
-- a table of overrides, e.g. `return { rust = false, go = false }`.
-- See `lua/config/langs_local.lua.example` for a template.

local defaults = {
    asm = true,
    ["c-cpp"] = true,
    cmake = true,
    dockerfile = true,
    go = true,
    json = true,
    just = true,
    lua = true,
    markdown = true,
    nix = true,
    protobuf = true,
    python = true,
    ron = true,
    rust = true,
    toml = true,
    web = true,
    yaml = true,
}

local ok, overrides = pcall(require, "config.langs_local")
if ok and type(overrides) == "table" then
    return vim.tbl_extend("force", defaults, overrides)
end
return defaults
