local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s(
        "df",
        fmt(
            [[
FROM {}

WORKDIR /app

COPY . .

RUN {}

CMD [{}]
]],
            { i(1, "alpine:latest"), i(2, "echo build"), i(0, '"sh"') }
        )
    ),
    -- multi-stage
    s(
        "multi",
        fmt(
            [[
FROM {} AS builder
WORKDIR /src
COPY . .
RUN {}

FROM {}
COPY --from=builder /src/{} /usr/local/bin/{}
ENTRYPOINT [{}]
]],
            {
                i(1, "golang:1-alpine"),
                i(2, "go build -o app ./..."),
                i(3, "alpine:latest"),
                i(4, "app"),
                i(5, "app"),
                i(0, '"/usr/local/bin/app"'),
            }
        )
    ),
    s(
        "hc",
        fmt(
            "HEALTHCHECK --interval={} --timeout={} --retries={} CMD {} || exit 1",
            { i(1, "30s"), i(2, "5s"), i(3, "3"), i(0, "curl -f http://localhost/") }
        )
    ),
    s("arg", fmt("ARG {}={}", { i(1, "NAME"), i(0, "default") })),
    s("env", fmt("ENV {}={}", { i(1, "NAME"), i(0, "value") })),
    -- non-root user
    s(
        "nru",
        fmt(
            [[
RUN addgroup -S {} && adduser -S {} -G {}
USER {}
]],
            { i(1, "app"), i(2, "app"), i(3, "app"), i(0, "app") }
        )
    ),
}
