local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("recipe", fmt("{}:\n    {}", { i(1, "name"), i(0, "command") })),
    s("dep", fmt("{}: {}\n    {}", { i(1, "name"), i(2, "dependency"), i(0, "command") })),
    s("param", fmt('{} {}="{}":\n    {}', { i(1, "name"), i(2, "arg"), i(3, "default"), i(0, "command {{arg}}") })),
    s("var", fmt('{} := "{}"', { i(1, "name"), i(0, "value") })),
    s("export", fmt('export {} := "{}"', { i(1, "NAME"), i(0, "value") })),
    s("alias", fmt("alias {} := {}", { i(1, "a"), i(0, "recipe") })),
    s("default", fmt("default:\n    @just --list", {})),
    s("sh", fmt("{}:\n    #!/usr/bin/env bash\n    set -euo pipefail\n    {}", { i(1, "name"), i(0, "command") })),
}
