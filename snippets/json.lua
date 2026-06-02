local u = require("config.snippets")
-- `f` uses `<>` delimiters so JSON `{}` braces stay literal.
local s, i, f = u.s, u.i, u.fmtd

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
