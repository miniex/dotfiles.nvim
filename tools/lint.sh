#!/bin/sh
# Lint Lua files: stylua format check + linter if available.
set -e

cd "$(dirname "$0")/.."

if ! command -v stylua >/dev/null 2>&1; then
    echo "stylua not found" >&2
    exit 1
fi

stylua --check .

if command -v selene >/dev/null 2>&1; then
    selene lua init.lua
elif command -v luacheck >/dev/null 2>&1; then
    luacheck lua init.lua
fi
