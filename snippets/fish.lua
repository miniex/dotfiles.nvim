local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

return {
    s("fn", fmt("function {}\n    {}\nend", { i(1, "name"), i(0) })),
    s("fnd", fmt('function {} -d "{}"\n    {}\nend', { i(1, "name"), i(2, "description"), i(0) })),
    s("arg", fmt("argparse {} -- $argv\nor return\n{}", { i(1, "'h/help'"), i(0) })),
    s("if", fmt("if test {}\n    {}\nend", { i(1, '-n "$var"'), i(0) })),
    s("for", fmt("for {} in {}\n    {}\nend", { i(1, "item"), i(2, "$list"), i(0) })),
    s(
        "switch",
        fmt("switch ${}\n    case {}\n        {}\n    case '*'\n        {}\nend", {
            i(1, "argv[1]"),
            i(2, "pattern"),
            i(3),
            i(0),
        })
    ),
}
