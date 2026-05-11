local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- import { ... } from "..."
    s("imp", fmt('import {{ {} }} from "{}";', { i(1, "name"), i(2, "module") })),
    -- import default
    s("impd", fmt('import {} from "{}";', { i(1, "name"), i(2, "module") })),
    -- export const arrow function
    s("ecf", fmt("export const {} = ({}): {} => {{\n    {}\n}};", { i(1, "name"), i(2), i(3, "void"), i(0) })),
    -- interface
    s("intf", fmt("interface {} {{\n    {}: {};\n}}", { i(1, "Name"), i(2, "field"), i(3, "string") })),
    -- type alias
    s("tya", fmt("type {} = {};", { i(1, "Name"), i(2, "string") })),
    -- async function
    s("afn", fmt("async function {}({}): Promise<{}> {{\n    {}\n}}", { i(1, "name"), i(2), i(3, "void"), i(0) })),
    -- describe / it (jest, vitest)
    s(
        "desc",
        fmt('describe("{}", () => {{\n    it("{}", () => {{\n        {}\n    }});\n}});', {
            i(1, "name"),
            i(2, "works"),
            i(0),
        })
    ),
    -- console.log
    s("cl", fmt("console.log({});", { i(1) })),
}
