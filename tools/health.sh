#!/bin/sh
# Diagnose host prerequisites for this Neovim config. Informational; never fails.
set -u

cd "$(dirname "$0")/.." || exit 1

green=''
yellow=''
red=''
reset=''
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    green=$(tput setaf 2 2>/dev/null || true)
    yellow=$(tput setaf 3 2>/dev/null || true)
    red=$(tput setaf 1 2>/dev/null || true)
    reset=$(tput sgr0 2>/dev/null || true)
fi

ok() { printf "  %s[OK]%s   %s\n" "$green" "$reset" "$1"; }
warn() { printf "  %s[WARN]%s %s\n" "$yellow" "$reset" "$1"; }
miss() { printf "  %s[MISS]%s %s\n" "$red" "$reset" "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }
na() { printf "  [--]   %s\n" "$1"; }
section() { printf "\n%s\n" "$1"; }

# $1 >= $2 (dotted versions). sort -V is GNU-only; fall back to awk on BSD/macOS.
version_ge() {
    if printf '' | sort -V >/dev/null 2>&1; then
        [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
    else
        awk -v a="$1" -v b="$2" 'BEGIN {
            na = split(a, x, "."); nb = split(b, y, ".")
            n = (na > nb ? na : nb)
            for (i = 1; i <= n; i++) {
                xi = x[i] + 0; yi = y[i] + 0
                if (xi > yi) exit 0
                if (xi < yi) exit 1
            }
            exit 0
        }'
    fi
}

section "Required"
for t in git tar curl xxd make less; do
    if have "$t"; then ok "$t"; else miss "$t not on PATH"; fi
done
if have rg; then ok "ripgrep (rg)"; else miss "ripgrep (binary 'rg') not on PATH"; fi
if have cc || have gcc || have clang; then
    ok "C compiler (cc/gcc/clang)"
else
    miss "no C compiler (need cc, gcc, or clang)"
fi

section "Neovim"
if have nvim; then
    nvim_v=$(nvim --version | head -n1 | awk '{print $2}' | sed 's/^v//')
    if version_ge "${nvim_v%-*}" "0.12.0"; then
        ok "nvim ${nvim_v} (>= 0.12.0)"
    else
        warn "nvim ${nvim_v} — config targets >= 0.12.0"
    fi
else
    miss "nvim not on PATH"
fi

section "Tree-sitter"
if have tree-sitter; then
    ts_v=$(tree-sitter --version 2>/dev/null | awk '{print $NF}')
    if version_ge "${ts_v%%-*}" "0.26.1"; then
        ok "tree-sitter ${ts_v} (>= 0.26.1)"
    else
        warn "tree-sitter ${ts_v} — need >= 0.26.1 (not the npm build)"
    fi
else
    miss "tree-sitter CLI not on PATH (install via cargo or distro, NOT npm)"
fi

section "Languages (enabled via langs.lua + langs_local.lua)"
enabled_langs=""
servers=""
if have nvim; then
    lsp_query=$(nvim --headless +'lua
local okl,langs=pcall(require,"config.langs")
local oks,map=pcall(require,"config.lang_servers")
if not (okl and oks) then return end
local okm,mlsp=pcall(require,"mason-lspconfig")
local inst={}
if okm then for _,s in ipairs(mlsp.get_installed_servers()) do inst[s]=true end end
local en={}
for lang,on in pairs(langs) do if on then en[#en+1]=lang end end
table.sort(en)
io.write("LANGS "..table.concat(en," ").."\n")
local seen,srv={},{}
for lang,on in pairs(langs) do if on and map[lang] then for _,s in ipairs(map[lang]) do if not seen[s] then seen[s]=true srv[#srv+1]=s..(inst[s] and ":1" or ":0") end end end end
table.sort(srv)
io.write("SERVERS "..table.concat(srv," ").."\n")' +qa 2>/dev/null)
    enabled_langs=$(printf '%s\n' "$lsp_query" | sed -n 's/^LANGS //p')
    servers=$(printf '%s\n' "$lsp_query" | sed -n 's/^SERVERS //p')
fi
if [ -n "$enabled_langs" ]; then
    ok "enabled: $enabled_langs"
else
    warn "could not query enabled languages (config load failed?)"
fi

# True when $1 is enabled (or the query failed, to avoid false skips).
lang_on() {
    [ -z "$enabled_langs" ] && return 0
    case " $enabled_langs " in
        *" $1 "*) return 0 ;;
        *) return 1 ;;
    esac
}

section "Mason LSP servers (enabled langs)"
if [ -n "$servers" ]; then
    # shellcheck disable=SC2086 # word-split the space-separated server list
    for entry in $servers; do
        if [ "${entry##*:}" = "1" ]; then
            ok "${entry%:*}"
        else
            miss "${entry%:*} not installed — :LspInstall ${entry%:*}"
        fi
    done
else
    warn "no server data (Mason or config not loaded)"
fi

section "Toolchains (Mason / per-lang)"
if have node; then ok "node $(node --version)"; else warn "node missing — npm-based Mason packages won't install"; fi
if have npm; then ok "npm $(npm --version)"; else warn "npm missing"; fi
if lang_on python; then
    if have python3; then ok "python3 $(python3 --version 2>&1 | awk '{print $2}')"; else warn "python3 missing — debugpy affected"; fi
    if have pip3 || have pip; then ok "pip available"; else warn "pip missing"; fi
else
    na "python3 / pip (python disabled)"
fi
if lang_on go; then
    if have go; then ok "go $(go version | awk '{print $3}')"; else warn "go missing — gopls / delve affected"; fi
else
    na "go (go disabled)"
fi
# cargo unconditional: fff.nvim build needs it regardless of rust.
if have cargo; then ok "cargo $(cargo --version | awk '{print $2}')"; else warn "cargo missing — rustaceanvim / fff.nvim build affected"; fi

section "Database client (vim-dadbod-ui)"
if lang_on sql; then
    db=
    for c in psql mysql sqlite3; do
        if have "$c"; then
            ok "$c"
            db=1
        fi
    done
    [ -n "$db" ] || warn "no DB client (psql / mysql / sqlite3) on PATH — :DBUI can't connect"
else
    na "sql disabled"
fi

section "Optional"
if have just; then ok "just"; else warn "just (justfile runner) not on PATH"; fi
if have lazygit; then ok "lazygit"; else warn "lazygit not on PATH — <leader>gg won't work"; fi
if have fzf; then ok "fzf"; else warn "fzf binary not on PATH — fzf-lua loses native fuzzy"; fi
if have magick; then ok "ImageMagick (magick)"; else warn "magick missing — snacks image previews disabled"; fi

section "Dev tooling (format / lint — see CONTRIBUTING.md)"
for t in stylua lua-language-server selene shfmt shellcheck; do
    if have "$t"; then ok "$t"; else warn "$t missing — needed by tools/format.sh / tools/lint.sh"; fi
done
for t in jq taplo yamlfmt; do
    if have "$t"; then ok "$t (optional formatter)"; else warn "$t missing — optional, format.sh skips it"; fi
done

section "Terminal / Fonts"
# kitty graphics protocol: kitty, WezTerm, and Ghostty all qualify.
if [ "${TERM:-}" = "xterm-kitty" ] || [ -n "${KITTY_WINDOW_ID:-}" ]; then
    ok "kitty detected (kitty graphics protocol available)"
elif [ -n "${WEZTERM_EXECUTABLE:-}" ] || [ -n "${WEZTERM_PANE:-}" ]; then
    ok "WezTerm detected (kitty graphics protocol available)"
elif [ "${TERM:-}" = "xterm-ghostty" ] || [ -n "${GHOSTTY_RESOURCES_DIR:-}" ] || [ -n "${GHOSTTY_BIN_DIR:-}" ]; then
    ok "Ghostty detected (kitty graphics protocol available)"
elif have kitty; then
    warn "kitty installed but TERM=${TERM:-unset} — image previews / symbol_map may not apply"
else
    warn "no graphics terminal (kitty/WezTerm/Ghostty) — inline image previews / MDI font fallback disabled"
fi

if have fc-list; then
    nerd_count=$(fc-list 2>/dev/null | grep -ciE "nerd font|symbols nerd font" || true)
    if [ "${nerd_count:-0}" -gt 0 ]; then
        ok "Nerd Font(s) installed (${nerd_count} faces matched)"
    else
        warn "no Nerd Font found via fc-list — icons will render as boxes"
    fi
    if fc-list 2>/dev/null | grep -qi "symbols nerd font mono"; then
        ok "Symbols Nerd Font Mono fallback present"
    else
        warn "Symbols Nerd Font Mono missing — many MDI glyphs (Supplementary PUA) won't render"
    fi
else
    warn "fc-list missing — cannot verify font installation"
fi

section "Clipboard bridge (yank → system)"
bridge=
for c in wl-copy xclip pbcopy clip.exe; do
    if have "$c"; then
        ok "$c available"
        bridge=1
        break
    fi
done
[ -n "$bridge" ] || warn "no clipboard tool found (wl-copy / xclip / pbcopy / clip.exe)"

section "Config load (headless smoke test)"
if have nvim; then
    runner="nvim"
    have timeout && runner="timeout 30 nvim"
    load_out=$($runner --headless "+lua print('NVIM_CONFIG_OK')" +qa 2>&1) || true
    # Match real nvim error formats, not a bare "error" substring.
    err_re='E[0-9]+:|Error detected|Error executing'
    if printf '%s' "$load_out" | grep -q "NVIM_CONFIG_OK" \
        && ! printf '%s' "$load_out" | grep -qE "$err_re"; then
        ok "config loads clean (headless)"
    else
        first=$(printf '%s\n' "$load_out" | grep -E "$err_re" | head -n1)
        warn "config emitted errors on load: ${first:-no sentinel (NVIM_CONFIG_OK) printed}"
    fi
else
    warn "nvim not on PATH — skipping config load test"
fi

printf "\nDone.\n"
