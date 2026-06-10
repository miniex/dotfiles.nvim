local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

return {
    -- proc
    s("proc", fmt("proc {}({}): {} =\n  {}", { i(1, "name"), i(2), i(3, "void"), i(0) })),
    -- object type
    s("type", fmt("type {} = object\n  {}: {}", { i(1, "Name"), i(2, "field"), i(3, "int") })),
    -- import
    s("imp", fmt("import {}", { i(0, "std/strutils") })),
    -- for / while
    s("for", fmt("for {} in {}:\n  {}", { i(1, "item"), i(2, "items"), i(0) })),
    s("while", fmt("while {}:\n  {}", { i(1, "cond"), i(0) })),
    -- if
    s("if", fmt("if {}:\n  {}", { i(1, "cond"), i(0) })),
    -- echo
    s("echo", fmt("echo {}", { i(0, '"hello"') })),
    -- iterator
    s("iter", fmt("iterator {}({}): {} =\n  {}", { i(1, "name"), i(2), i(3, "int"), i(0) })),
    -- when (compile-time branch)
    s("when", fmt("when {}:\n  {}", { i(1, "defined(release)"), i(0) })),
}
