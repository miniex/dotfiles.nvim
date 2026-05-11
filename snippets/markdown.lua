local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- fenced code block
    s("code", fmt("```{}\n{}\n```", { i(1, "lang"), i(0) })),
    -- link
    s("link", fmt("[{}]({})", { i(1, "text"), i(2, "url") })),
    -- image
    s("img", fmt("![{}]({})", { i(1, "alt"), i(2, "url") })),
    -- table (2x2 skeleton)
    s("tbl", fmt("| {} | {} |\n| --- | --- |\n| {} | {} |", { i(1, "h1"), i(2, "h2"), i(3), i(0) })),
    -- frontmatter (YAML)
    s(
        "fm",
        fmt(
            "---\ntitle: {}\ndate: {}\n---\n\n{}",
            { i(1, "Title"), f(function()
                return os.date("%Y-%m-%d")
            end), i(0) }
        )
    ),
    -- task / checkbox
    s("task", fmt("- [ ] {}", { i(0, "todo") })),
    -- details/summary collapsible
    s("det", fmt("<details>\n<summary>{}</summary>\n\n{}\n\n</details>", { i(1, "click to expand"), i(0) })),
}
