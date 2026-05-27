local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- #[derive(...)]
    s("der", fmt("#[derive({})]", { i(1, "Debug, Clone") })),
    -- single #[test] function
    s("tst", fmt("#[test]\nfn {}() {{\n    {}\n}}", { i(1, "name"), i(0, "assert!(true);") })),
    -- #[cfg(test)] mod tests scaffold
    s(
        "mt",
        fmt(
            [[
#[cfg(test)]
mod tests {{
    use super::*;

    #[test]
    fn {}() {{
        {}
    }}
}}
]],
            { i(1, "it_works"), i(0, "assert_eq!(2 + 2, 4);") }
        )
    ),
    -- impl block
    s("imp", fmt("impl {} {{\n    {}\n}}", { i(1, "Type"), i(0) })),
    -- match expression
    s("mat", fmt("match {} {{\n    {} => {},\n}}", { i(1, "expr"), i(2, "_"), i(0, "()") })),
    -- enum
    s("enm", fmt("enum {} {{\n    {},\n}}", { i(1, "Name"), i(0, "Variant") })),
    -- trait
    s("trt", fmt("trait {} {{\n    fn {}(&self){};\n}}", { i(1, "Name"), i(2, "method"), i(0) })),
    -- async fn
    s("afn", fmt("async fn {}({}) -> {} {{\n    {}\n}}", { i(1, "name"), i(2), i(3, "Result<()>"), i(0) })),
    -- if let Some
    s("ifl", fmt("if let Some({}) = {} {{\n    {}\n}}", { i(1, "x"), i(2, "expr"), i(0) })),
    -- if let Ok
    s("ife", fmt("if let Ok({}) = {} {{\n    {}\n}}", { i(1, "x"), i(2, "expr"), i(0) })),
}
