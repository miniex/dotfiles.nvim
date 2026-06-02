# shellcheck shell=sh
# Shared ANSI palette for install.sh / set-lang.sh — source, don't execute.
# TTY-only: piped/non-TTY leaves every var empty so callers stay quiet.
# shellcheck disable=SC2034 # consumed by the sourcing script, not here

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
