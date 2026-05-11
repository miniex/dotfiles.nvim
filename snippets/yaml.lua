local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- GitHub Actions workflow skeleton
    s(
        "gha",
        fmt(
            [[
name: {}

on:
  push:
    branches: [{}]

jobs:
  {}:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: {}
        run: {}
]],
            { i(1, "ci"), i(2, "main"), i(3, "build"), i(4, "build"), i(0, "make") }
        )
    ),
    -- generic job step
    s("step", fmt("- name: {}\n  run: {}", { i(1, "name"), i(0, "cmd") })),
    -- docker-compose service skeleton
    s(
        "svc",
        fmt(
            [[
{}:
  image: {}
  ports:
    - "{}:{}"
  environment:
    {}: {}
]],
            { i(1, "name"), i(2, "image:tag"), i(3, "8080"), i(4, "8080"), i(5, "KEY"), i(0, "value") }
        )
    ),
    -- yaml anchor & alias
    s("anc", fmt("&{} {}", { i(1, "name"), i(0) })),
}
