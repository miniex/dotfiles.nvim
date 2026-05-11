local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- if __name__ == "__main__":
    s("main", fmt('if __name__ == "__main__":\n    {}', { i(0, "main()") })),
    -- @dataclass scaffold
    s(
        "dcls",
        fmt(
            [[
from dataclasses import dataclass


@dataclass
class {}:
    {}: {} = {}
]],
            { i(1, "Name"), i(2, "field"), i(3, "str"), i(4, '""') }
        )
    ),
    -- pytest test function
    s("deft", fmt("def test_{}():\n    {}", { i(1, "name"), i(0, "assert True") })),
    -- breakpoint() call
    s("bp", fmt("breakpoint()", {})),
}
