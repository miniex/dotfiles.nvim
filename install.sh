#!/bin/sh
# Bootstrap installer for miniex/dotfiles.nvim.
# Run: sh -c "$(curl -fsSL https://raw.githubusercontent.com/miniex/dotfiles.nvim/main/install.sh)"
set -eu

REPO_URL="https://github.com/miniex/dotfiles.nvim.git"
NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

# Shared palette. When bootstrapped via `curl | sh` the repo isn't on disk yet,
# so fall back to inline definitions if scripts/_colors.sh can't be resolved.
# shellcheck disable=SC1007 # `CDPATH=` is a deliberate env prefix for `cd`
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd 2>/dev/null) || script_dir=''
if [ -n "$script_dir" ] && [ -r "$script_dir/scripts/_colors.sh" ]; then
    . "$script_dir/scripts/_colors.sh"
elif [ -t 1 ]; then
    RESET=$(printf '\033[0m')
    BOLD=$(printf '\033[1m')
    DIM=$(printf '\033[2m')
    SKY=$(printf '\033[38;2;135;206;235m')
    PINK=$(printf '\033[38;2;255;182;193m')
    SKY2=$(printf '\033[38;2;165;200;225m')
    PINK2=$(printf '\033[38;2;225;188;204m')
    YELLOW=$(printf '\033[33m')
    RED=$(printf '\033[31m')
else
    RESET=''
    BOLD=''
    DIM=''
    SKY=''
    PINK=''
    SKY2=''
    PINK2=''
    YELLOW=''
    RED=''
fi

banner() {
    printf '\n'
    printf '   %s%s╭──────────────────────────────────────────────╮%s\n' "$SKY" "$BOLD" "$RESET"
    printf '   %s%s│  %sminiex/dotfiles.nvim%s%s%s                        %s%s│%s\n' \
        "$SKY" "$BOLD" "$PINK" "$RESET" "$SKY" "$BOLD" "$SKY" "$BOLD" "$RESET"
    printf '   %s%s│  %sNeovim configuration installer%s%s%s              %s%s│%s\n' \
        "$SKY2" "$BOLD" "$PINK2" "$RESET" "$SKY2" "$BOLD" "$SKY2" "$BOLD" "$RESET"
    printf '   %s%s╰──────────────────────────────────────────────╯%s\n' "$PINK" "$BOLD" "$RESET"
    printf '\n'
}

step() { printf '\n%s%s▸ %s%s\n' "$BOLD" "$SKY" "$1" "$RESET"; }
info() { printf '  %sℹ%s  %s\n' "$SKY" "$RESET" "$1"; }
ok() { printf '  %s✓%s  %s\n' "$PINK" "$RESET" "$1"; }
warn() { printf '  %s⚠%s  %s\n' "$YELLOW" "$RESET" "$1"; }
err() { printf '  %s✗%s  %s\n' "$RED" "$RESET" "$1" >&2; }

# Read from /dev/tty so prompts work even when piped from curl.
prompt_yes() {
    printf '  %s?%s  %s %s[y/N]%s ' "$PINK" "$RESET" "$1" "$DIM" "$RESET"
    if [ -r /dev/tty ]; then
        read -r answer </dev/tty
    else
        answer=''
    fi
    case "$answer" in
        [yY] | [yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

backup_path() { printf '%s.backup.%s' "$1" "$(date +%Y%m%d-%H%M%S)"; }

# $1 >= $2 (dotted versions). sort -V is GNU-only; awk fallback for BSD/macOS.
version_ge() {
    if printf '' | sort -V >/dev/null 2>&1; then
        [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
    else
        awk -v a="$1" -v b="$2" 'BEGIN {
            na = split(a, x, "."); nb = split(b, y, "."); n = (na > nb ? na : nb)
            for (i = 1; i <= n; i++) { xi = x[i] + 0; yi = y[i] + 0
                if (xi > yi) exit 0; if (xi < yi) exit 1 }
            exit 0
        }'
    fi
}

banner

step "Pre-flight checks"
if ! command -v git >/dev/null 2>&1; then
    err "git not found — install it first"
    exit 1
fi
ok "git"

if command -v nvim >/dev/null 2>&1; then
    nvim_version=$(nvim --version | head -n 1 | awk '{print $2}' | sed 's/^v//')
    if version_ge "${nvim_version%%-*}" "0.12.0"; then
        ok "nvim $nvim_version"
    else
        warn "nvim $nvim_version is below the required 0.12.0 — upgrade before launching"
    fi
else
    warn "nvim not installed — install Neovim ≥ 0.12.0 before launching"
fi

step "Existing config"
already_cloned=
if [ -e "$NVIM_CONFIG" ]; then
    origin=
    [ -d "$NVIM_CONFIG/.git" ] && origin=$(git -C "$NVIM_CONFIG" remote get-url origin 2>/dev/null \
        || git -C "$NVIM_CONFIG" config --get remote.origin.url 2>/dev/null || true)
    case "$origin" in
        *miniex/dotfiles.nvim*)
            # Already this repo → update in place instead of backup-or-abort.
            if prompt_yes "$NVIM_CONFIG is already this config. Pull latest?"; then
                if git -C "$NVIM_CONFIG" pull --ff-only; then
                    ok "updated $NVIM_CONFIG"
                else
                    warn "pull failed (local changes / diverged) — resolve manually"
                fi
            else
                info "left as-is"
            fi
            already_cloned=1
            ;;
        *)
            bk=$(backup_path "$NVIM_CONFIG")
            if prompt_yes "Move $NVIM_CONFIG → $bk?"; then
                mv "$NVIM_CONFIG" "$bk"
                ok "config moved to $bk"
            else
                err "aborted — config already exists at $NVIM_CONFIG"
                exit 1
            fi
            ;;
    esac
else
    info "no existing $NVIM_CONFIG"
fi

if [ -n "$already_cloned" ]; then
    info "keeping existing plugin data (update)"
elif [ -e "$NVIM_DATA" ]; then
    bk=$(backup_path "$NVIM_DATA")
    if prompt_yes "Move $NVIM_DATA → $bk? (recommended for clean plugin install)"; then
        mv "$NVIM_DATA" "$bk"
        ok "data moved to $bk"
    else
        info "skipped data backup"
    fi
else
    info "no existing $NVIM_DATA"
fi

step "Clone repository"
if [ -n "$already_cloned" ]; then
    info "using existing clone"
else
    git clone --depth 1 "$REPO_URL" "$NVIM_CONFIG"
    ok "cloned to $NVIM_CONFIG"
fi

step "Language selection"
if [ -r /dev/tty ] && prompt_yes "Run interactive language picker now?"; then
    sh "$NVIM_CONFIG/set-lang.sh" </dev/tty
else
    info "skipped — a core language set is enabled by default"
    info "run 'sh $NVIM_CONFIG/set-lang.sh' anytime to enable more"
fi

step "Done"
ok "miniex/dotfiles.nvim installed at $NVIM_CONFIG"
printf '\n  %sNext:%s\n' "$BOLD" "$RESET"
printf '    %s•%s launch %s%snvim%s — Lazy/Mason install plugins on first run\n' "$PINK" "$RESET" "$SKY" "$BOLD" "$RESET"
printf '    %s•%s see %s%s%s/README.md%s for keymaps and customization\n\n' "$PINK" "$RESET" "$SKY" "$BOLD" "$NVIM_CONFIG" "$RESET"
