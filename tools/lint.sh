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
ls_logdir="${TMPDIR:-/tmp}/lua-ls-check.$$"
trap 'rm -rf "$ls_logdir"' EXIT
lua-language-server --check . --logpath "$ls_logdir"
selene .

# Tracked shell scripts: every *.sh plus the extensionless term-bin shim.
sh_files="$(git ls-files '*.sh' 2>/dev/null || true) scripts/term-bin/nvim"
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
