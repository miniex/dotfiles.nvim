-- Lang toggle: a core set is on by default; enable the rest with `set-lang.sh`
-- (or hand-edit gitignored `langs_local.lua`, which overrides this; see *.example).
local defaults = {
    asm = false,
    astro = false,
    bash = true,
    ["c-cpp"] = true,
    cmake = false,
    dockerfile = true,
    elixir = false,
    fish = false,
    go = true,
    graphql = false,
    helm = false,
    json = true,
    just = false,
    lua = true,
    markdown = true,
    nim = false,
    nix = false,
    ocaml = false,
    php = false,
    protobuf = false,
    python = true,
    ron = false,
    rust = true,
    shader = false,
    sql = true,
    svelte = false,
    terraform = false,
    toml = true,
    typst = false,
    vue = false,
    web = true,
    yaml = true,
    zig = false,
}

local ok, overrides = pcall(require, "config.langs_local")
if ok and type(overrides) == "table" then
    return vim.tbl_extend("force", defaults, overrides)
end
return defaults
