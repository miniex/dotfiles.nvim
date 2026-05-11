local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- safe shebang
    s("sh", fmt("#!/usr/bin/env bash\nset -euo pipefail\n\n{}", { i(0) })),
    -- function
    s("fn", fmt("{}() {{\n    {}\n}}", { i(1, "name"), i(0) })),
    -- if
    s("if", fmt("if [[ {} ]]; then\n    {}\nfi", { i(1, '-n "$var"'), i(0) })),
    -- for loop
    s("for", fmt("for {} in {}; do\n    {}\ndone", { i(1, "f"), i(2, '"$@"'), i(0) })),
    -- case
    s(
        "case",
        fmt('case "${}" in\n    {})\n        {}\n        ;;\n    *)\n        {}\n        ;;\nesac', {
            i(1, "1"),
            i(2, "pattern"),
            i(3),
            i(0),
        })
    ),
    -- usage / die helper
    s("die", fmt('die() {{\n    printf "%s\\n" "$*" >&2\n    exit 1\n}}', {})),
}
