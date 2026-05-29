local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("syntax", fmt('syntax = "{}";', { i(0, "proto3") })),
    s("pkg", fmt("package {};", { i(0, "name") })),
    s("import", fmt('import "{}";', { i(0, "path.proto") })),
    s("msg", fmt("message {} {{\n  {}\n}}", { i(1, "Name"), i(0) })),
    s("field", fmt("{} {} = {};", { i(1, "string"), i(2, "name"), i(0, "1") })),
    s("rep", fmt("repeated {} {} = {};", { i(1, "string"), i(2, "name"), i(0, "1") })),
    s("enum", fmt("enum {} {{\n  {} = 0;\n  {}\n}}", { i(1, "Name"), i(2, "UNSPECIFIED"), i(0) })),
    s("svc", fmt("service {} {{\n  {}\n}}", { i(1, "Name"), i(0) })),
    s("rpc", fmt("rpc {}({}) returns ({});", { i(1, "Method"), i(2, "Request"), i(0, "Response") })),
    s("oneof", fmt("oneof {} {{\n  {}\n}}", { i(1, "name"), i(0) })),
    s("map", fmt("map<{}, {}> {} = {};", { i(1, "string"), i(2, "string"), i(3, "name"), i(0, "1") })),
}
