local u = require("config.snippets")
local s, i, rep, fmt = u.s, u.i, u.rep, u.fmt

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
            { i(1, "ci"), i(2, "main"), i(3, "build"), rep(3), i(0, "make") }
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
            { i(1, "name"), i(2, "image:tag"), i(3, "8080"), rep(3), i(4, "KEY"), i(0, "value") }
        )
    ),
    -- yaml anchor & alias
    s("anc", fmt("&{} {}", { i(1, "name"), i(0) })),
    -- k8s Deployment
    s(
        "kdeploy",
        fmt(
            [[
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {}
spec:
  replicas: {}
  selector:
    matchLabels:
      app: {}
  template:
    metadata:
      labels:
        app: {}
    spec:
      containers:
        - name: {}
          image: {}
]],
            { i(1, "app"), i(2, "1"), rep(1), rep(1), rep(1), i(0, "image:tag") }
        )
    ),
    -- k8s Service
    s(
        "ksvc",
        fmt(
            [[
apiVersion: v1
kind: Service
metadata:
  name: {}
spec:
  selector:
    app: {}
  ports:
    - port: {}
      targetPort: {}
]],
            { i(1, "app"), rep(1), i(2, "80"), i(0, "8080") }
        )
    ),
    -- k8s ConfigMap
    s(
        "kcm",
        fmt(
            [[
apiVersion: v1
kind: ConfigMap
metadata:
  name: {}
data:
  {}: {}
]],
            { i(1, "config"), i(2, "KEY"), i(0, "value") }
        )
    ),
}
