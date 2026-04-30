#!/bin/sh
# Format all Lua files with stylua.
set -e

cd "$(dirname "$0")/.."

if ! command -v stylua >/dev/null 2>&1; then
    echo "stylua not found" >&2
    exit 1
fi

stylua .
