local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("let", fmt("let {} = {}", { i(1, "x"), i(0) })),
    s("letin", fmt("let {} = {} in\n{}", { i(1, "x"), i(2), i(0) })),
    s("rec", fmt("let rec {} {} =\n  {}", { i(1, "f"), i(2, "x"), i(0) })),
    s("fun", fmt("fun {} -> {}", { i(1, "x"), i(0) })),
    s("match", fmt("match {} with\n| {} -> {}\n| _ -> {}", { i(1, "x"), i(2, "Some v"), i(3), i(0) })),
    s("module", fmt("module {} = struct\n  {}\nend", { i(1, "Name"), i(0) })),
    s("type", fmt("type {} =\n  | {}\n  | {}", { i(1, "t"), i(2, "A"), i(0, "B") })),
    s("rectype", fmt("type {} = {{\n  {} : {};\n}}", { i(1, "t"), i(2, "field"), i(0, "int") })),
    s("open", fmt("open {}", { i(0, "Module") })),
    s("if", fmt("if {} then {} else {}", { i(1, "cond"), i(2), i(0) })),
    s("pr", fmt('Printf.printf "{}\\n" {}', { i(1, "%s"), i(0) })),
}
