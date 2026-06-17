local markers = require("config.lsp_markers")

return {
    root_markers = vim.list_extend(vim.list_extend({}, markers.python), { ".git" }),
    -- Semantic tokens off centrally (lsp/init.lua); keeps the bundled on_attach (LspPyright* cmds).
    settings = {
        basedpyright = {
            -- Cede import organizing to ruff (avoids a duplicate organize-imports action).
            disableOrganizeImports = true,
            analysis = {
                -- Skip heavy non-source trees so enumeration stays fast (the >10s warning).
                -- A custom exclude overrides pyright's default, so the first 3 re-add it.
                exclude = {
                    "**/node_modules",
                    "**/__pycache__",
                    "**/.*", -- .venv / .git / .mypy_cache / .ruff_cache / .pytest_cache / …
                    "**/venv",
                    "**/env",
                    "**/site-packages",
                    "**/build",
                    "**/dist",
                    "**/target", -- Rust / Maven
                    "**/vendor", -- Go vendored deps
                    "**/_build", -- Elixir / OCaml (dune)
                    "**/deps", -- Elixir fetched deps
                    "**/zig-out", -- Zig
                    "**/_opam", -- OCaml local opam switch
                    "**/result", -- Nix build output (symlink → /nix/store)
                    "**/result-*", -- Nix extra outputs (result-bin, result-dev, …)
                },
                typeCheckingMode = "standard",
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                inlayHints = {
                    variableTypes = true,
                    functionReturnTypes = true,
                    callArgumentNames = true,
                    genericTypes = false,
                },
            },
        },
    },
}
