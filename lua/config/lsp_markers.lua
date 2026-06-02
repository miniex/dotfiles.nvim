-- Reusable LSP root_markers shared across server configs in lsp/*.lua.
-- Order is priority (0.11+), so compose, don't reorder.
return {
    -- Python project roots, shared by basedpyright + ruff.
    python = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile" },
}
