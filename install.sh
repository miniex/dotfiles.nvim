#!/bin/sh
# Bootstrap installer for miniex/dotfiles.nvim.
# Run: sh -c "$(curl -fsSL https://raw.githubusercontent.com/miniex/dotfiles.nvim/main/install.sh)"
set -eu

REPO_URL="https://github.com/miniex/dotfiles.nvim.git"
NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

if [ -t 1 ]; then
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

banner

step "Pre-flight checks"
if ! command -v git >/dev/null 2>&1; then
    err "git not found — install it first"
    exit 1
fi
ok "git"

if command -v nvim >/dev/null 2>&1; then
    nvim_version=$(nvim --version | head -n 1 | awk '{print $2}')
    ok "nvim $nvim_version"
else
    warn "nvim not installed — install Neovim ≥ 0.12.0 before launching"
fi

step "Backup existing"
if [ -e "$NVIM_CONFIG" ]; then
    bk=$(backup_path "$NVIM_CONFIG")
    if prompt_yes "Move $NVIM_CONFIG → $bk?"; then
        mv "$NVIM_CONFIG" "$bk"
        ok "config moved to $bk"
    else
        err "aborted — config already exists at $NVIM_CONFIG"
        exit 1
    fi
else
    info "no existing $NVIM_CONFIG"
fi

if [ -e "$NVIM_DATA" ]; then
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
git clone --depth 1 "$REPO_URL" "$NVIM_CONFIG"
ok "cloned to $NVIM_CONFIG"

step "Language selection"
if [ -r /dev/tty ] && prompt_yes "Run interactive language picker now?"; then
    sh "$NVIM_CONFIG/set-lang.sh" </dev/tty
else
    info "skipped — all languages enabled by default"
    info "run 'sh $NVIM_CONFIG/set-lang.sh' anytime to choose"
fi

step "Done"
ok "miniex/dotfiles.nvim installed at $NVIM_CONFIG"
printf '\n  %sNext:%s\n' "$BOLD" "$RESET"
printf '    %s•%s launch %s%snvim%s — Lazy/Mason install plugins on first run\n' "$PINK" "$RESET" "$SKY" "$BOLD" "$RESET"
printf '    %s•%s see %s%s%s/README.md%s for keymaps and customization\n\n' "$PINK" "$RESET" "$SKY" "$BOLD" "$NVIM_CONFIG" "$RESET"
