-- Lang toggle. Override via gitignored `lua/config/langs_local.lua` (see *.example).
local defaults = {
    asm = true,
    astro = true,
    bash = true,
    ["c-cpp"] = true,
    cmake = true,
    dockerfile = true,
    elixir = true,
    fish = true,
    go = true,
    graphql = true,
    helm = true,
    json = true,
    just = true,
    lua = true,
    markdown = true,
    nim = true,
    nix = true,
    ocaml = true,
    php = true,
    protobuf = true,
    python = true,
    ron = true,
    rust = true,
    shader = true,
    sql = true,
    svelte = true,
    terraform = true,
    toml = true,
    typst = true,
    vue = true,
    web = true,
    yaml = true,
    zig = true,
}

local ok, overrides = pcall(require, "config.langs_local")
if ok and type(overrides) == "table" then
    return vim.tbl_extend("force", defaults, overrides)
end
return defaults
