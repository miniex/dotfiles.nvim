local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- package main + main()
    s("main", fmt('package main\n\nimport "fmt"\n\nfunc main() {{\n    {}\n}}', { i(0, 'fmt.Println("hello")') })),
    -- err check
    s("iferr", fmt("if err != nil {{\n    return {}\n}}", { i(0, "err") })),
    -- err check with wrap
    s("iferrf", fmt('if err != nil {{\n    return fmt.Errorf("{}: %w", err)\n}}', { i(0, "context") })),
    -- func
    s("fn", fmt("func {}({}) {} {{\n    {}\n}}", { i(1, "name"), i(2), i(3, "error"), i(0) })),
    -- method (pointer receiver)
    s(
        "meth",
        fmt(
            "func ({} *{}) {}({}) {} {{\n    {}\n}}",
            { i(1, "r"), i(2, "Type"), i(3, "name"), i(4), i(5, "error"), i(0) }
        )
    ),
    -- struct
    s("st", fmt("type {} struct {{\n    {} {}\n}}", { i(1, "Name"), i(2, "Field"), i(3, "string") })),
    -- interface
    s("intf", fmt("type {} interface {{\n    {}({}) {}\n}}", { i(1, "Name"), i(2, "Method"), i(3), i(4, "error") })),
    -- test function
    s("tst", fmt("func Test{}(t *testing.T) {{\n    {}\n}}", { i(1, "Name"), i(0, 't.Fatal("not implemented")') })),
    -- table-driven test
    s(
        "tstt",
        fmt(
            [[
func Test{}(t *testing.T) {{
    cases := []struct {{
        name string
        {}
    }}{{
        {{name: "{}"}},
    }}
    for _, tc := range cases {{
        t.Run(tc.name, func(t *testing.T) {{
            {}
        }})
    }}
}}
]],
            { i(1, "Name"), i(2, "in, want int"), i(3, "first"), i(0) }
        )
    ),
}
