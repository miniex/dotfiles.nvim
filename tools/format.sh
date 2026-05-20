#!/bin/sh
# Format Lua (stylua), shell (shfmt); optionally JSON (jq), TOML (taplo),
# and YAML (yamlfmt) when those tools are on PATH.
set -eu

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

if command -v jq >/dev/null 2>&1; then
    # lazy-lock.json is plugin-managed; never touch.
    git ls-files '*.json' 2>/dev/null | while IFS= read -r f; do
        [ "$f" = "lazy-lock.json" ] && continue
        tmp=$(mktemp)
        if jq --indent 4 . "$f" >"$tmp"; then
            mv "$tmp" "$f"
        else
            rm -f "$tmp"
            echo "warn: jq failed on $f" >&2
        fi
    done
fi

if command -v taplo >/dev/null 2>&1; then
    git ls-files '*.toml' 2>/dev/null | xargs -r taplo fmt
fi

if command -v yamlfmt >/dev/null 2>&1; then
    git ls-files '*.yml' '*.yaml' 2>/dev/null | xargs -r yamlfmt
fi
