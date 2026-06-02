local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

return {
    s("imp", fmt('import {{ {} }} from "{}";', { i(1, "name"), i(2, "module") })),
    s("impd", fmt('import {} from "{}";', { i(1, "name"), i(2, "module") })),
    s("req", fmt('const {} = require("{}");', { i(1, "name"), i(2, "module") })),
    s("ecf", fmt("export const {} = ({}) => {{\n    {}\n}};", { i(1, "name"), i(2), i(0) })),
    s("afn", fmt("async function {}({}) {{\n    {}\n}}", { i(1, "name"), i(2), i(0) })),
    s(
        "desc",
        fmt('describe("{}", () => {{\n    it("{}", () => {{\n        {}\n    }});\n}});', {
            i(1, "name"),
            i(2, "works"),
            i(0),
        })
    ),
    s("cl", fmt("console.log({});", { i(1) })),
}
