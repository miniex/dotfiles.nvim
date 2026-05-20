local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("tbl", fmt("[{}]\n{} = {}", { i(1, "section"), i(2, "key"), i(0, '"value"') })),
    s("arr", fmt("[[{}]]\n{} = {}", { i(1, "items"), i(2, "name"), i(0, '"value"') })),
    s("inl", fmt("{} = {{ {} = {} }}", { i(1, "key"), i(2, "name"), i(0, '"value"') })),
    -- Cargo dependency entry
    s("dep", fmt('{} = {{ version = "{}", features = [{}] }}', { i(1, "crate"), i(2, "1"), i(0) })),
    -- pyproject.toml [project]
    s(
        "pyproj",
        fmt(
            [[
[project]
name = "{}"
version = "{}"
description = "{}"
requires-python = ">={}"
dependencies = [
    {}
]
]],
            { i(1, "name"), i(2, "0.1.0"), i(3), i(4, "3.11"), i(0) }
        )
    ),
    -- Cargo.toml [package]
    s(
        "cargopkg",
        fmt(
            [[
[package]
name = "{}"
version = "{}"
edition = "{}"

[dependencies]
{}
]],
            { i(1, "name"), i(2, "0.1.0"), i(3, "2024"), i(0) }
        )
    ),
    s("mtx", fmt("{} = [{}]", { i(1, "os"), i(0, '"ubuntu-latest", "macos-latest"') })),
    -- key = same key (rep)
    s("kv", fmt("{} = {}", { i(1, "key"), rep(1) })),
}
