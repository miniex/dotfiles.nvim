#!/bin/sh
# Format Lua (stylua) and shell scripts (shfmt).
set -e

cd "$(dirname "$0")/.."

missing=
for tool in stylua shfmt; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        missing="$missing $tool"
    fi
done

if [ -n "$missing" ]; then
    echo "missing required tool(s):$missing" >&2
    exit 1
fi

stylua .
shfmt -w -i 4 -ci -bn -s install.sh set-lang.sh tools/format.sh tools/lint.sh
