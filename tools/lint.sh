#!/bin/sh
# Lint Lua (stylua + lua-language-server + selene), shell (shfmt + shellcheck),
# and any tracked fish/zsh scripts (fish -n / zsh -n).
set -eu

cd "$(dirname "$0")/.."

missing=
for tool in stylua lua-language-server selene shfmt shellcheck; do
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
lua-language-server --check . --logpath "${TMPDIR:-/tmp}/lua-ls-check.$$"
selene .

sh_files="install.sh set-lang.sh tools/format.sh tools/lint.sh tools/health.sh scripts/_colors.sh scripts/term-bin/nvim"
# shellcheck disable=SC2086 # word-splitting the file list is intentional
shfmt -d -i 4 -ci -bn -s $sh_files
# shellcheck disable=SC2086
shellcheck $sh_files

# Parse-only check on any tracked files matching $1 using `$2 -n`. Warn-if-absent.
check_parse() {
    [ -n "$(git ls-files "$1" 2>/dev/null)" ] || return 0
    if command -v "$2" >/dev/null 2>&1; then
        git ls-files -z "$1" 2>/dev/null | xargs -0 -n1 "$2" -n
    else
        echo "warn: $1 present but '$2' not on PATH" >&2
    fi
}

if command -v git >/dev/null 2>&1; then
    check_parse '*.fish' fish
    check_parse '*.zsh' zsh
fi
