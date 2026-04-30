#!/bin/sh
# Lint Lua: stylua format check + lua-language-server diagnostics.
# Contributor/maintainer tool — both binaries must be on PATH.
set -e

cd "$(dirname "$0")/.."

missing=
for tool in stylua lua-language-server; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        missing="$missing $tool"
    fi
done

if [ -n "$missing" ]; then
    echo "missing required tool(s):$missing" >&2
    echo "install via your package manager (brew/apt/cargo/etc.)" >&2
    exit 1
fi

stylua --check .

lua-language-server --check . --logpath /tmp/lua-ls-check
