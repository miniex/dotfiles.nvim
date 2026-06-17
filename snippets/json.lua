local u = require("config.snippets")
-- fmtd uses `<>` delimiters so JSON `{}` braces stay literal.
local s, i, fmtd = u.s, u.i, u.fmtd

return {
    s(
        "pkg",
        fmtd(
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
        fmtd(
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
    s("schema", fmtd('"$schema": "<>"', { i(0, "https://json.schemastore.org/package.json") })),
}
