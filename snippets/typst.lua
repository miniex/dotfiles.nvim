local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s(
        "doc",
        fmt(
            [[
#set page(numbering: "1")
#set text(font: "{}", size: {}pt)
#set par(justify: true)

= {}

{}
]],
            { i(1, "New Computer Modern"), i(2, "11"), i(3, "Title"), i(0) }
        )
    ),
    s("h", fmt("= {}", { i(0, "Heading") })),
    s("h2", fmt("== {}", { i(0, "Heading") })),
    s(
        "fig",
        fmt(
            [[
#figure(
  image("{}", width: {}),
  caption: [{}],
) <{}>
]],
            { i(1, "img.png"), i(2, "80%"), i(3, "caption"), i(0, "label") }
        )
    ),
    s("eq", fmt("$ {} $", { i(0, "a^2 + b^2 = c^2") })),
    s(
        "table",
        fmt(
            [[
#table(
  columns: {},
  {}
)
]],
            { i(1, "2"), i(0) }
        )
    ),
    s("let", fmt("#let {} = {}", { i(1, "name"), i(0, "value") })),
    s("imp", fmt('#import "{}": {}', { i(1, "@preview/pkg:0.1.0"), i(0, "*") })),
}
