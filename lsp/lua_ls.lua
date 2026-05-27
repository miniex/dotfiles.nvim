return {
    root_markers = { ".luarc.json", ".luarc.jsonc", "stylua.toml", ".stylua.toml", "selene.toml", ".git" },
    settings = {
        Lua = {
            workspace = { checkThirdParty = false },
            codeLens = { enable = true },
            completion = { callSnippet = "Replace" },
            doc = { privateName = { "^_" } },
            hint = {
                enable = true,
                setType = true,
                paramType = true,
                paramName = "Literal",
                semicolon = "Disable",
                arrayIndex = "Auto",
                await = true,
            },
        },
    },
}
