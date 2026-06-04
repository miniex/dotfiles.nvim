return {
    filetypes = { "graphql", "typescriptreact", "javascriptreact" },
    -- Scope to graphql projects; .git deliberately omitted so plain React/TS repos don't attach.
    root_markers = {
        ".graphqlrc",
        ".graphqlrc.json",
        ".graphqlrc.yaml",
        ".graphqlrc.yml",
        ".graphqlrc.toml",
        ".graphqlrc.js",
        ".graphqlrc.ts",
        "graphql.config.json",
        "graphql.config.yaml",
        "graphql.config.yml",
        "graphql.config.toml",
        "graphql.config.js",
        "graphql.config.ts",
        ".graphqlconfig",
    },
}
