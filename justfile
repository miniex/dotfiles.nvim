# dotfiles.nvim task runner. Recipes wrap tools/*.sh.

# show available recipes.
default:
    @just --list

# format Lua / shell / JSON / TOML / YAML (+ this justfile).
fmt:
    ./tools/format.sh

# lint Lua / shell (+ justfile format & parse).
lint:
    ./tools/lint.sh

# check host prerequisites.
health:
    ./tools/health.sh
