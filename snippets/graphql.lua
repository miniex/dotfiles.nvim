local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("type", fmt("type {} {{\n  {}\n}}", { i(1, "Name"), i(0) })),
    s("input", fmt("input {} {{\n  {}\n}}", { i(1, "Name"), i(0) })),
    s("interface", fmt("interface {} {{\n  {}\n}}", { i(1, "Name"), i(0) })),
    s("enum", fmt("enum {} {{\n  {}\n}}", { i(1, "Name"), i(0) })),
    s("union", fmt("union {} = {} | {}", { i(1, "Name"), i(2, "A"), i(0, "B") })),
    s("scalar", fmt("scalar {}", { i(0, "DateTime") })),
    s("field", fmt("{}: {}", { i(1, "name"), i(0, "String!") })),
    s("frag", fmt("fragment {} on {} {{\n  {}\n}}", { i(1, "Name"), i(2, "Type"), i(0) })),
    s("query", fmt("query {} {{\n  {}\n}}", { i(1, "Name"), i(0) })),
    s("mut", fmt("mutation {} {{\n  {}\n}}", { i(1, "Name"), i(0) })),
}
