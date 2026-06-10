#!/bin/sh
# Interactive language toggle for this Neovim config.
# Run: sh ~/.config/nvim/set-lang.sh
set -eu

config_dir="$(cd "$(dirname "$0")" && pwd)"
local_file="$config_dir/lua/config/langs_local.lua"
defaults_file="$config_dir/lua/config/langs.lua"

if [ ! -f "$defaults_file" ]; then
    echo "langs.lua not found at $defaults_file" >&2
    exit 1
fi

# Shared palette (always present alongside this script in a clone).
. "$config_dir/scripts/_colors.sh"

# Is $1 a member of the space-separated list $2?
in_list() {
    case " $2 " in
        *" $1 "*) return 0 ;;
        *) return 1 ;;
    esac
}

# langs = every available language (picker list, true|false); default_off = the
# off-by-default ones. (Two greps: BSD grep mishandles the bracket/bare alternation.)
langs=$({
    grep -E '^[[:space:]]*\["[^"]+"\][[:space:]]*=[[:space:]]*(true|false)' "$defaults_file"
    grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*(true|false)' "$defaults_file"
} | sed -E 's/^[[:space:]]*//; s/[[:space:]]*=.*$//; s/^\["//; s/"\]$//' | sort -u | tr '\n' ' ')
default_off=$({
    grep -E '^[[:space:]]*\["[^"]+"\][[:space:]]*=[[:space:]]*false' "$defaults_file"
    grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*false' "$defaults_file"
} | sed -E 's/^[[:space:]]*//; s/[[:space:]]*=.*$//; s/^\["//; s/"\]$//' | tr '\n' ' ')

n=$(echo "$langs" | wc -w | tr -d ' ')
if [ "$n" -eq 0 ]; then
    echo "no languages parsed from $defaults_file" >&2
    exit 1
fi

# Initial checkbox state = langs.lua defaults, then langs_local.lua overrides.
local_true=""
local_false=""
if [ -f "$local_file" ]; then
    local_true=$({
        grep -E '^[[:space:]]*\["[^"]+"\][[:space:]]*=[[:space:]]*true' "$local_file" 2>/dev/null || true
        grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*true' "$local_file" 2>/dev/null || true
    } | sed -E 's/^[[:space:]]*//; s/[[:space:]]*=.*$//; s/^\["//; s/"\]$//' | tr '\n' ' ')
    local_false=$({
        grep -E '^[[:space:]]*\["[^"]+"\][[:space:]]*=[[:space:]]*false' "$local_file" 2>/dev/null || true
        grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*false' "$local_file" 2>/dev/null || true
    } | sed -E 's/^[[:space:]]*//; s/[[:space:]]*=.*$//; s/^\["//; s/"\]$//' | tr '\n' ' ')
fi
disabled=""
for lang in $langs; do
    if in_list "$lang" "$local_true"; then
        : # explicitly enabled
    elif in_list "$lang" "$local_false" || in_list "$lang" "$default_off"; then
        disabled="$disabled $lang"
    fi
done

ESC=$(printf '\033')
CR=$(printf '\r')

is_disabled() {
    case " $disabled " in
        *" $1 "*) return 0 ;;
        *) return 1 ;;
    esac
}

toggle() {
    if is_disabled "$1"; then
        disabled=$(echo " $disabled " | sed "s/ $1 / /g; s/^ *//; s/ *$//")
    else
        disabled="$disabled $1"
    fi
}

draw() {
    printf '\033[H\033[J'
    printf '\n'
    printf '   %s%s╭──────────────────────────────────────────────╮%s\n' "$SKY" "$BOLD" "$RESET"
    printf '   %s%s│  %sNeovim language picker%s%s%s                      %s%s│%s\n' \
        "$SKY2" "$BOLD" "$PINK" "$RESET" "$SKY2" "$BOLD" "$SKY2" "$BOLD" "$RESET"
    printf '   %s%s╰──────────────────────────────────────────────╯%s\n' "$PINK" "$BOLD" "$RESET"
    printf '\n'

    i=0
    for lang in $langs; do
        if is_disabled "$lang"; then
            mark="${DIM}[ ]${RESET}"
            name="${DIM}${lang}${RESET}"
        else
            mark="${SKY}[✓]${RESET}"
            name="${lang}"
        fi
        if [ "$i" -eq "$cursor" ]; then
            printf '   %s▸%s  %s  %s\n' "$PINK" "$RESET" "$mark" "$name"
        else
            printf '      %s  %s\n' "$mark" "$name"
        fi
        i=$((i + 1))
    done

    printf '\n'
    printf '   %s%s↑/↓%s move   %s%sspace%s toggle   %s%sa%s all   %s%sn%s none   %s%s↩%s save   %s%sq%s quit\n' \
        "$BOLD" "$PINK" "$RESET" \
        "$BOLD" "$PINK" "$RESET" \
        "$BOLD" "$PINK" "$RESET" \
        "$BOLD" "$PINK" "$RESET" \
        "$BOLD" "$PINK" "$RESET" \
        "$BOLD" "$PINK" "$RESET"
}

cleanup() {
    stty echo icanon 2>/dev/null || true
    printf '\033[?25h'
}
trap cleanup INT TERM EXIT

if [ ! -t 0 ] || [ ! -r /dev/tty ]; then
    echo "set-lang.sh needs an interactive terminal." >&2
    echo "Edit lua/config/langs_local.lua by hand for non-interactive setups." >&2
    exit 1
fi

cursor=0
stty -echo -icanon
printf '\033[?25l'
draw

while :; do
    key=$(dd if=/dev/tty bs=1 count=1 2>/dev/null)
    case "$key" in
        "$ESC")
            # Lone ESC has no trailing bytes; VTIME avoids blocking.
            stty min 0 time 1
            rest=$(dd if=/dev/tty bs=1 count=2 2>/dev/null)
            stty min 1 time 0
            case "$rest" in
                '[A') if [ "$cursor" -gt 0 ]; then cursor=$((cursor - 1)); fi ;;
                '[B') if [ "$cursor" -lt $((n - 1)) ]; then cursor=$((cursor + 1)); fi ;;
            esac
            ;;
        ' ')
            i=0
            for lang in $langs; do
                if [ "$i" -eq "$cursor" ]; then
                    toggle "$lang"
                    break
                fi
                i=$((i + 1))
            done
            ;;
        a | A) disabled='' ;;
        n | N) disabled="$langs" ;;
        "$CR" | '') break ;;
        q | Q)
            cleanup
            printf '\n   %scancelled.%s\n\n' "$YELLOW" "$RESET"
            exit 0
            ;;
    esac
    draw
done

cleanup
printf '\n'

# Atomic write (temp + mv): an interrupt must not leave a half-file Neovim sources.
# Only languages whose state differs from the langs.lua default are written.
tmp_file="$local_file.tmp.$$"
{
    echo '-- Generated by set-lang.sh. Overrides langs.lua defaults; hand-edits are'
    echo '-- preserved on next run only if they match the [name] = bool shape.'
    echo 'return {'
    for lang in $langs; do
        if in_list "$lang" "$default_off"; then def_on=0; else def_on=1; fi
        if in_list "$lang" "$disabled"; then state=0; else state=1; fi
        if [ "$state" -ne "$def_on" ]; then
            [ "$state" -eq 1 ] && val=true || val=false
            case "$lang" in
                *[!a-zA-Z0-9_]*) printf '    ["%s"] = %s,\n' "$lang" "$val" ;;
                *) printf '    %s = %s,\n' "$lang" "$val" ;;
            esac
        fi
    done
    echo '}'
} >"$tmp_file"
mv "$tmp_file" "$local_file"

printf '   %s✓%s  saved to %s%s%s%s\n' "$PINK" "$RESET" "$SKY" "$BOLD" "$local_file" "$RESET"
printf '   %sℹ%s  restart nvim for changes to take effect.\n\n' "$SKY" "$RESET"
