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
# Tracked shell scripts: every *.sh plus the extensionless term-bin shim.
sh_files="$(git ls-files '*.sh' 2>/dev/null || true) scripts/term-bin/nvim"
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

# `xargs -r` is GNU-only; guard empty input instead so this also works on BSD/macOS.
if command -v taplo >/dev/null 2>&1 && [ -n "$(git ls-files '*.toml' 2>/dev/null)" ]; then
    git ls-files -z '*.toml' 2>/dev/null | xargs -0 taplo fmt
fi

if command -v yamlfmt >/dev/null 2>&1 && [ -n "$(git ls-files '*.yml' '*.yaml' 2>/dev/null)" ]; then
    git ls-files -z '*.yml' '*.yaml' 2>/dev/null | xargs -0 yamlfmt
fi

# justfile: `just --fmt` is gated behind --unstable.
if command -v just >/dev/null 2>&1 && [ -f justfile ]; then
    just --fmt --unstable
fi
