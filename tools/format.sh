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
sh_files="install.sh set-lang.sh tools/format.sh tools/lint.sh tools/health.sh scripts/_colors.sh scripts/term-bin/nvim"
# shellcheck disable=SC2086 # word-splitting the file list is intentional
shfmt -w -i 4 -ci -bn -s $sh_files

if command -v jq >/dev/null 2>&1; then
    # lazy-lock.json is plugin-managed; never touch.
    git ls-files '*.json' 2>/dev/null | while IFS= read -r f; do
        [ "$(basename "$f")" = "lazy-lock.json" ] && continue
        # In-place rewrite preserves mode/owner (mktemp+mv would reset to 0600);
        # capture first so $f is only written on jq success.
        if formatted=$(jq --indent 4 . "$f"); then
            printf '%s\n' "$formatted" >"$f"
        else
            echo "warn: jq failed on $f" >&2
        fi
    done
fi

if command -v taplo >/dev/null 2>&1; then
    git ls-files -z '*.toml' 2>/dev/null | xargs -0r taplo fmt
fi

if command -v yamlfmt >/dev/null 2>&1; then
    git ls-files -z '*.yml' '*.yaml' 2>/dev/null | xargs -0r yamlfmt
fi
