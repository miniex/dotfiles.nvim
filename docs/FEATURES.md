# Features

## LSP & Completion

- **Native LSP** — `vim.lsp.config` + `after/lsp/<server>.lua` discovery; mason-tool-installer installs the servers, the config enables them itself (gated by enabled langs + executable presence). Workspace root anchors on language manifests, `.git` as fallback.
- **File watching** — client-side `didChangeWatchedFiles` is on for every server (off by default on Linux); rust-analyzer watches server-side so large projects don't stall on open.
- **Inlay hints** — toggle per buffer with `<leader>ci`; suppressed automatically during insert mode.
- **CodeLens** — enabled on capable servers (gopls, rust-analyzer, lua_ls, ocamllsp, elixir-ls); refreshes on edit, paused during insert mode (like inlay hints); skipped on big files, as is the idle reference-highlight.
- **Navigation** — `gd` / `gr` / `gI` / `gy` open an fzf-lua picker (auto-jumps on a single result); `<leader>cI` / `cG` / `cH` for incoming / outgoing calls + type hierarchy.
- **Rename** — `<leader>rn` via inc-rename with a live in-buffer preview.
- **Formatting** — `<leader>cf` runs `vim.lsp.buf.format` (native LSP; no formatter plugin). `gq` / `gw` route through the LSP formatter on code filetypes (via `formatexpr`); prose (markdown / gitcommit) keeps Neovim's built-in reflow.
- **Semantic tokens** — off by default on TS (vtsls), Python (basedpyright), and C/C++ (clangd), where they clash with treesitter highlight; toggle per buffer with `<leader>uy` (survives `:LspRestart`).
- **Colors** — colorizer highlights hex (and CSS functions in style files); LSP document colors are left at nvim defaults.
- **Linked editing** — an HTML/JSX tag and its closing tag rename in sync via native `vim.lsp.linked_editing_range` on capable servers (html, …).
- **Diagnostics** — single config in `lua/plugins/lsp/init.lua`; `tiny-inline-diagnostic.nvim` owns virtual text. Severity-sorted, signs `✗`/`!`/`i`/`?`.
- **Spell check** — `typos_lsp` across all filetypes: low false-positive (only known typos), surfaced at `Info` severity.
- **Completion** — [blink.cmp](https://github.com/Saghen/blink.cmp) with Rust fuzzy matching + inline ghost-text preview. Sources: LSP / snippets (LuaSnip + friendly-snippets) / path / buffer; filtered per filetype (`gitcommit` uses a `git` source via blink-cmp-git + path/buffer, no LSP in `gitrebase`, buffer-only in snacks input prompts). Cmdline completion on `:` (commands / paths) and `/` `?` (search).
- **LSP restart** — `<leader>cs` for when a server hangs.

## Treesitter

- `main` branch (master is archived and incompatible with 0.12).
- Modules: textobjects (`af`/`if`/`ac`/`ic`/`aa`/`ia` + jumps), sticky context (`treesitter-context`), `nvim-ts-autotag`.
- Node-wise visual selection via 0.12 natives: `an` / `in` expand-to-parent / shrink-to-child, `]n` / `[n` next / prev sibling.
- Auto-installs missing parsers on launch: a core set plus each enabled lang's parsers (disabled langs install nothing).
- Big-file guard — skips highlight/indent on files >1 MiB or with a >2000-char first line (snacks.bigfile degrades >2 MiB).

## Pickers

- **fff** — Rust-backed file finder. `<leader>ff` for cwd, `<leader>fF` for current dir.
- **snacks.picker** — recent / buffers / help / TODOs / projects. `<leader>fr` / `<leader>fb` / `<leader>fh` / `<leader>ft` / `<leader>fp` (projects: cd + restore session). `<leader>fB` live-greps open buffers only; `<leader>fi` / `<leader>fH` insert an icon / inspect highlight groups.
- **fzf-lua** — live grep (`<leader>fg`) + git / LSP / grep / lines / snippets / history under `<leader>z*`.
- fff and snacks share the same 0.85 × 0.85 chrome-aware rectangle. Picker previews (snacks, fzf-lua) drop their left border so the list's right border is a single `✿│✿` divider; fff takes flower borders via `layout.border`.

## Editor

- **Files** — `<leader>e` opens oil: edit a directory as a buffer (rename / move / delete-to-trash, LSP-aware), current path in the winbar, git status per file / folder (oil-git: colored name + `~` `+` `?`, folders `*`); it doesn't hijack directory buffers, so `nvim <dir>` still lands on the dashboard.
- **Big files** — snacks.bigfile degrades >2 MiB files; lighter guards from 1 MiB. Size tiers in [CUSTOMIZATION](CUSTOMIZATION.md#big-file-handling).
- **Navigation** — flash (`s` / `S`), Trouble (`<leader>xx`), aerial (`<leader>cO`), stock `[b`/`]b` buffers and `[l`/`]l` loclist, smart-splits (`<C-hjkl>` across nvim splits + tmux/wezterm panes).
- **Search & replace** — grug-far (`<leader>rr`).
- **Quickfix** — quicker.nvim (editable QF, `>`/`<` context), Trouble (`auto_close` on jump, main-window preview; `<leader>x*` lists diagnostics / refs / symbols / call hierarchy / type defs / implementations).
- **Misc** — mini.surround (`gs*`), mini.ai (`a`/`i` brackets/quotes/tags + `aN`/`aL` next/last, `ag` buffer / `ad` number), mini.move (`<A-hjkl>` line shuffle), mini.operators (`gR` replace-with-register / `gX` exchange / `gS` sort / `g=` eval), built-in `gc` (treesitter-aware; `gco` / `gcO` / `gcA` rebuilt in `keymaps.lua`), todo-comments, tiny-code-action (`<leader>ca` picker with per-action diff preview), nvim-colorizer (6/8-digit hex everywhere; 3/4-digit `#RGB` shorthand only in CSS-family, so issue/PR refs like `#590` aren't colorized; skipped on big/minified files), rainbow-delimiters (on-theme nested bracket-pair colors; disabled on big/minified files), 0.12 built-ins `:Undotree` and `:DiffTool` (non-git side-by-side file/dir diff), hex.nvim (`<leader>ux` toggle hex view).
- **Persistence** — `persistence.nvim` auto-restores on bare `nvim` (skipping headless, empty sessions, and `nvim <file>` launches, which neither restore nor save). Only window-visible buffers persist (no hidden `badd`). Neotest summary window state persists across sessions. Sessions are scoped per git branch (feature branches keep distinct layouts; main/master share the base session).
- **Width-aware `textwidth`** — `rust` / `python` / `lua` / `elixir` / `ocaml` / `c`-`cpp` / `sql` / `toml` set `textwidth` (the `gq`/`gw` reflow width) to the formatter's default line width (`.editorconfig` `max_line_length` overrides) — no visual ruler. See [CUSTOMIZATION](CUSTOMIZATION.md#formatter-width).

## UI

- **Theme** — Catppuccin Mocha retoned to a 2-color **damin** palette: `#98ABCC` (blue) / `#E890B0` (pink). Mirrors [`fish-theme-damin`](https://github.com/miniex/fish-theme-damin) + [`dotfiles.kitty`](https://github.com/miniex/dotfiles.kitty) + [`dotfiles.tmux`](https://github.com/miniex/dotfiles.tmux).
- **statusline** — hand-rolled global statusline ([`lua/config/statusline.lua`](../lua/config/statusline.lua)); plain text, transparent. Left: 3-letter mode (`NOR` / `INS` / `VIS` / `V-L` / `V-B` / `REP` / `CMD` / `TRM` …, mode-colored), `@x` while recording a macro, git branch, relative path + `[+]` / `[RO]`, diagnostic counts (`E1 W2 I1 H1`). Right: LSP progress (spinner + title, `✓ <client>` on end), attached LSP client names, gitsigns diff (`+a ~c -r`), off-default encoding / line-ending (non-`utf-8` / non-`unix` only), `searchcount()` match `[cur/total]` (cached; skipped above 20000 lines), `line:col` + `%P`. Empty on the dashboard.
- **Buffers** — no tabline. `<S-h>` / `<S-l>` or `[b` / `]b` cycle, `<leader>fb` picks.
- **cursor bloom** — `✿` sign on the current line in mode color (custom autocmd in [`lua/config/cursor-bloom.lua`](../lua/config/cursor-bloom.lua)). Refresh defer skips picker/terminal/chrome buffers.
- **which-key** — hint floats pinned to the bottom row at 85% editor width (centered); height grows with content. `timeoutlen=300`.
- **Floating windows** — every float in the config (LSP hover / signature / diagnostic, snacks panels, fzf-lua, fff, blink.cmp menu / signature / docs, neotest, which-key, Mason, lazy, lazygit, checkhealth) shares one look: `✿` flower-cornered border (`✿─✿│✿─✿│`), pink edge, transparent background, centered `✿ title ✿`. Configured in [`lua/config/globals.lua`](../lua/config/globals.lua).
- **flash labels** — damin pink.
- **indent guides** — uniform `┊` dotted guides (snacks.indent), no scope highlight (`[i`/`]i` still jump to scope edges); chunk off.
- **zen** — `<leader>uz` focus mode hides the statusline (flower-bordered window).
- **smear-cursor** — blocky "pixel" trail: quadrant blocks only (no diagonals), 4 flat shade steps, short capped tail, no overshoot. `j` / `k` and short `h` / `l` moves don't animate, only real jumps. Off in pickers (`filetypes_disabled`) and across windows (`smear_between_buffers = false`), so float opens never streak.
- **Side panels** — aerial / trouble / dap / neotest open in their plugins' default positions.

## Modal floats

Big floating UIs (pickers / terminal / lazy / Mason / lazygit / checkhealth) are mutually exclusive — opening one closes the others. Hover, completion, signature, and notifications stack freely on top.

All modals share a single 0.85 × 0.85 chrome-aware rectangle defined in [`lua/config/modal-geom.lua`](../lua/config/modal-geom.lua):

- snacks picker / terminal / lazygit read it via function callbacks
- lazy / Mason use their own 0.85 size option
- fzf-lua reads it from a `winopts` function
- fff has its own chrome-aware layout that already matches
- checkhealth opens as a native float (`vim.g.health.style`, nvim 0.12) — no report tab to flash

See [`lua/config/modal-floats.lua`](../lua/config/modal-floats.lua) for the mutual-exclusion registry.

## Git

- **gitsigns** — gutter signs, hunk staging (`<leader>gh*`, `ghs` toggles stage/unstage), hunk textobject (`ih`/`ah`), inline blame (off by default — toggle `<leader>gtb`), word-diff toggle (`<leader>gtw`), full hunk diff via `<leader>ghp` (centered modal, cursor lands inside) or inline via `<leader>ghi`; `]h`/`[h` hunk nav auto-previews and is `;`/`,`-repeatable (`]H`/`[H` for staged hunks); `<leader>ghQ` sends all-repo hunks to quickfix, `<leader>ghv` views the file at the index.
- **fugitive** — `<leader>gs` status, `<leader>gd` diff, `<leader>gD` 3-way merge diff.
- **lazygit** — `Snacks.lazygit`, auto-themed to the colorscheme. `<leader>gg` open / `<leader>gf` file history / `<leader>gL` log.

## Tooling

- **nvim-lint** — runs on save / read (not `InsertLeave`) with a per-buffer 250ms debounce; skips run if you switched away.
- **mason-tool-installer** — single source of truth for Mason installs: LSP servers plus non-LSP tools (shellcheck, golangci-lint, eslint_d, selene, markdownlint, statix, hadolint, sqlfluff, yamllint, …). `auto_update` stays off; a startup toast flags tools with updates (`:MasonToolsUpdate`).
- **DAP** — Rust (rustaceanvim's codelldb) / C-C++ (codelldb) / Python (debugpy) / Go (delve) / Zig (codelldb) / Nim (codelldb) / Elixir (elixir-ls debug adapter) / JS-TS (js-debug-adapter for Node; browser auto-detected from `$PATH` — Chrome, else Firefox; probed lazily, not at startup) / PHP (php-debug-adapter; needs Xdebug) / Bash (bash-debug-adapter / BashDB). C/C++, Zig, Nim, and Rust all resolve codelldb through `lua/config/codelldb.lua`. Persistent breakpoints per-cwd; conditional / hit-condition / log-point breakpoints (`<leader>dB`/`dH`/`dL`); exception breakpoints via `<leader>dE`; reads project `.vscode/launch.json`.
- **neotest** — Python (pytest) / Go (gotestsum) / Elixir (mix) / C/C++ (gtest + ctest: Catch2 / doctest) / Lua (busted + plenary) / Rust (rustaceanvim) / Zig / JS-TS (vitest / jest) / PHP (PHPUnit). Summary window state restored across sessions.
- **Python venv** — basedpyright auto-detects the interpreter (`$VIRTUAL_ENV` / `.venv` / `venv`); `:LspPyrightSetPythonPath` switches it.
- **overseer** — task / build runner (`<leader>R*`); auto-detects make / npm / cargo / go / just / cmake templates.
- **nvim-coverage** — test-coverage gutter signs + summary (`<leader>nc` / `nC`, toggle `nv` / clear `nX`); reads lcov / coverage.xml.
- **iron** — send-to-REPL for python / lua / sh / elixir / js-ts (`<leader>i*`).
- **package-info** — npm dependency versions inline in `package.json` (`<leader>cv` / `cu` / `cU` / `cD`).
- **crates.nvim** — Cargo.toml dependency versions inline (`<leader>cv` / `cF` / `cu` / `cU` / `cD`).
- **kulala** — in-editor REST/HTTP client for `.http` / `.rest` files (`<leader>k*`): run / replay / inspect / copy-as-curl.
- **health check** — `:checkhealth` opens as a native float (not a report tab). `:checkhealth dotfiles` is the in-editor host check (enabled langs → Mason servers, toolchains, DB client, clipboard, terminal/fonts); `just check` is the shell equivalent plus dev-tooling and a config-load smoke test.

## Markdown

- `mdx_analyzer` handles `.mdx`; `marksman` handles `.md`. Highlighting via treesitter; spelling via `typos_lsp`.
- `markdownlint` (nvim-lint) runs a relaxed ruleset — stylistic nags (line length, inline HTML, bare URLs, …) are disabled in `lua/plugins/lsp/lint.lua`; structural / correctness rules stay on.

## Database

- **vim-dadbod-ui** — `<leader>uD` toggles the DB drawer; `:DBUIAddConnection` to register a URL, then browse / query per connection.
- **vim-dadbod-completion** — table / column completion in blink.cmp for `sql` / `mysql` / `plsql` (alongside `sqls`).
- Needs the engine's client CLI on `$PATH` (`psql` / `mysql` / `sqlite3`).
- **sqls** — the SQL LSP reads connections from `~/.config/sqls/config.yml` (`sqls config`); with none set it's keyword-only.

## Native ui2

- Floating cmdline + messages via `vim._core.ui2.enable()`.
- Opt out with `vim.g.disable_ui2 = true` in `options.lua`.

## Clipboard

`y` yanks are copied to the system clipboard through nvim's own provider (wl-copy / xclip / xsel / pbcopy / clip.exe / win32yank; OSC52 over SSH), debounced 50ms. Other operators (`d`, `c`) stay out of the clipboard.

## snacks.nvim modules in use

picker · profiler · terminal · dashboard · notifier · indent · scope · image · bigfile · quickfile · bufdelete · input · scratch · zen · words · lazygit · gitbrowse · rename (LSP-aware).

`:q` / `:x` / `ZZ` are stock. On the dashboard `<leader>w` jumps to a file buffer if any, else exits. `<leader>;` peeks and returns to the alternate on the next press. Persistence quietly swaps dashboard windows out before saving so the session restores cleanly. Footer surfaces a `<leader>qs` hint when a session exists for the cwd.

## Launch modes

How you start Neovim sets the workspace behavior:

- **`nvim`** (no args) — full IDE: dashboard, and the cwd session auto-restores on start and saves on exit.
- **`nvim <dir>`** — identical to `cd <dir> && nvim`: chdir's into `<dir>` (dropping the stray dir buffer) and keys the session to `<dir>`, landing on the dashboard or the cwd's restored session (an inaccessible dir is a file launch: no session).
- **`nvim <file…>`** (or several dirs, or piped stdin) — opens the args as buffers; the session is left untouched.

This keeps `nvim <file>` from disturbing a directory's saved workspace. Set via `vim.g.file_launch` / `vim.g.dir_launch` in `lua/config/globals.lua`.
