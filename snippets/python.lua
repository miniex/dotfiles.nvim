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
    -- with statement
    s("wth", fmt("with {} as {}:\n    {}", { i(1, "open(path)"), i(2, "f"), i(0) })),
    -- async def
    s("adef", fmt("async def {}({}) -> {}:\n    {}", { i(1, "name"), i(2), i(3, "None"), i(0) })),
    -- decorator factory
    s(
        "dec",
        fmt(
            [[
def {}(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper
]],
            { i(1, "name") }
        )
    ),
    -- generator
    s("gen", fmt("def {}({}):\n    yield {}", { i(1, "name"), i(2), i(0) })),
    -- try/except
    s(
        "try",
        fmt("try:\n    {}\nexcept {} as {}:\n    {}", { i(1, "pass"), i(2, "Exception"), i(3, "e"), i(0, "raise") })
    ),
    -- pytest fixture
    s("fxt", fmt("@pytest.fixture\ndef {}({}):\n    {}", { i(1, "name"), i(2), i(0, "return None") })),
}
