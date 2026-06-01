local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
-- `<>` delimiters so JSON `{}` braces stay literal.
local function f(str, nodes)
    return fmt(str, nodes, { delimiters = "<>" })
end

return {
    s(
        "pkg",
        f(
            [[
{
  "name": "<>",
  "version": "<>",
  "type": "module",
  "scripts": {
    "<>": "<>"
  }
}]],
            { i(1, "app"), i(2, "0.1.0"), i(3, "dev"), i(0, "vite") }
        )
    ),
    s(
        "tsconfig",
        f(
            [[
{
  "compilerOptions": {
    "target": "<>",
    "module": "<>",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}]],
            { i(1, "ES2022"), i(0, "ESNext") }
        )
    ),
    s("schema", f('"$schema": "<>"', { i(0, "https://json.schemastore.org/package.json") })),
}
