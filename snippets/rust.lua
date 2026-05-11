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
}
