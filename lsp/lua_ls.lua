return {
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
