# Features

## LSP & Completion

- **Native LSP** — `vim.lsp.config` + `lsp/<server>.lua` discovery; mason-tool-installer installs the servers, the config enables them itself (gated by enabled langs + executable presence). Workspace root anchors on language manifests, `.git` as fallback.
- **File watching** — client-side `didChangeWatchedFiles` is on for every server (off by default on Linux); rust-analyzer watches server-side so large projects don't stall on open.
- **Inlay hints** — toggle per buffer with `<leader>ci`; suppressed automatically during insert mode.
- **CodeLens** — enabled on capable servers (gopls, rust-analyzer, lua_ls, ocamllsp, elixir-ls); refreshes on edit, paused during insert mode (like inlay hints); skipped on big files, as is the idle reference-highlight.
- **Navigation** — `gd` / `gr` / `gi` / `gy` open an fzf-lua picker (auto-jumps on a single result); `<leader>cI` / `cG` / `cH` for incoming / outgoing calls + type hierarchy.
- **Rename** — `<leader>rn` via inc-rename with a live in-buffer preview.
- **Formatting** — `<leader>cf` runs `vim.lsp.buf.format` (native LSP; no formatter plugin). `gq` / `gw` route through the LSP formatter on code filetypes (via `formatexpr`); prose (markdown / gitcommit) keeps Neovim's built-in reflow.
- **Semantic tokens** — off by default on TS (vtsls), Python (basedpyright), and C/C++ (clangd), where they clash with treesitter highlight; toggle per buffer with `<leader>uy` (survives `:LspRestart`).
- **Document colors** — LSP color swatches via native `vim.lsp.document_color` on any capable server (tailwindcss, cssls, …), enabled by a short bounded poll after attach (capability can register post-init); colorizer still owns hex.
- **Linked editing** — an HTML/JSX tag and its closing tag rename in sync via native `vim.lsp.linked_editing_range` on capable servers (html, …).
- **Diagnostics** — single config in `lua/plugins/lsp/init.lua`; `tiny-inline-diagnostic.nvim` owns virtual text. Severity-sorted, signs `✗`/`!`/`i`/`?`.
- **Spell check** — `typos_lsp` across all filetypes: low false-positive (only known typos), surfaced at `Info` severity.
- **Completion** — [blink.cmp](https://github.com/Saghen/blink.cmp) with Rust fuzzy matching + inline ghost-text preview. Sources: LSP / snippets (LuaSnip + friendly-snippets) / path / buffer; filtered per filetype (`gitcommit` uses a `git` source via blink-cmp-git + path/buffer, no LSP in `gitrebase`, buffer-only in snacks input prompts). Cmdline completion on `:` (commands / paths) and `/` `?` (search).
- **LSP restart** — `<leader>cs` for when a server hangs.

## Treesitter

- `main` branch (master is archived and incompatible with 0.12).
- Modules: textobjects (`af`/`if`/`ac`/`ic`/`aa`/`ia` + jumps), sticky context (`treesitter-context`), `nvim-ts-autotag`, `ts-context-commentstring`.
- Node-wise visual selection via 0.12 natives: `an` / `in` expand-to-parent / shrink-to-child, `]n` / `[n` next / prev sibling.
- Auto-installs missing parsers on first launch with an early-exit poll.
- Big-file guard — skips highlight/indent on files >1 MiB or with a >2000-char first line (snacks.bigfile degrades >2 MiB).

## Pickers

- **fff.nvim** — Rust-backed file finder. `<leader>ff` for cwd, `<leader>fF` for current dir.
- **snacks.picker** — grep / recent / buffers / help / TODOs / projects. `<leader>fg` / `<leader>fr` / `<leader>fb` / `<leader>fh` / `<leader>ft` / `<leader>fp` (projects: cd + restore session). `<leader>fB` live-greps open buffers only; `<leader>fi` / `<leader>fH` insert an icon / inspect highlight groups.
- **fzf-lua** — git / LSP / grep / lines / snippets / history. `<leader>z*` namespace.
- fff and snacks share the same 0.85 × 0.85 chrome-aware rectangle. The snacks picker's preview overlaps the list's right border by 1 column so a single `✿│✿` divider is drawn between them (matches fff's "shared middle flower" effect).

## Editor

- **Files** — Neo-tree (floating). `<leader>e` toggle, `<leader>o` reveal current file. Directory rows show recursive total size instead of the default `-` — scanned on a libuv worker thread (off the main loop), rows spin then fill in; the spinner redraw yields to navigation, so scrolling stays smooth. Sizes use IEC binary units (KiB/MiB). The root row carries the directory's grand total, marked `Σ` (yields to the column's `▲/▼` sort indicator when ordering by size). `<leader>-` opens yazi, a full-screen TUI file manager (needs the `yazi` binary). `<leader>O` opens oil — edit a directory as a buffer (rename / move / delete-to-trash, LSP-aware); it doesn't hijack directory buffers, so `nvim <dir>` still lands on the dashboard.
- **Big files** — opening a file >8 MiB prompts: view in `less` (default) / edit / cancel (binary skips the pager). `<leader>L` views the current file in `less` anytime. Size tiers in [CUSTOMIZATION](CUSTOMIZATION.md#big-file-handling).
- **Navigation** — flash (`s` / `S`), Trouble (`<leader>xx`), aerial (`<leader>cO`), harpoon v2 (`<leader>m*`), nvim-spider (camelCase-aware `w`/`e`/`b`/`ge`), mini.bracketed (`[j`/`]j` jumplist, `[u`/`]u` undo, `[l`/`]l` loclist), smart-splits (`<C-hjkl>` across nvim splits + tmux/wezterm panes), treewalker (`<A-arrows>` move / `<A-S-arrows>` swap by AST node), precognition (`<leader>uP` toggleable motion hints).
- **Search & replace** — grug-far (`<leader>rr`) for regex; ssr (`<leader>rs`) for structural AST-aware replace.
- **Structural edits & yank ring** — treesj split/join a node (`<leader>cJ`); yanky yank history (`]y` / `[y` after paste, `]p` / `[p` reindent paste, `<leader>yh` to pick from the ring); various-textobjs indentation / value / key / subword / URL objects (`iI` / `iv` / `ik` / `ie` / `iu`).
- **Multi-cursor** — multicursor.nvim under `<leader>M*` + `<C-Up>` / `<C-Down>`.
- **Smart inc/dec** — dial.nvim. `<C-a>`/`<C-x>` flips bools, dates, semver, hex colors, identifier case, `&&↔||` (plus `let↔const` in JS/TS and headers in markdown).
- **Quickfix** — quicker.nvim (editable QF), nvim-bqf (preview), Trouble (`auto_close` on jump, main-window preview; `<leader>x*` lists diagnostics / refs / symbols / call hierarchy / type defs / implementations).
- **Misc** — mini.surround (`gs*`), mini.ai (`a`/`i` brackets/quotes/tags + `aN`/`aL` next/last, `ag` buffer / `ad` number), mini.move (`<A-hjkl>` line shuffle), mini.operators (`gR` replace-with-register / `gX` exchange / `gS` sort / `g=` eval), Comment.nvim (`gc` toggle), refactoring.nvim (`<leader>cr` extract/inline), todo-comments, dropbar (winbar), git-conflict, nvim-lightbulb (code-action sign; skipped on big/minified files), tiny-code-action (`<leader>ca` picker with per-action diff preview), nvim-colorizer (6/8-digit hex everywhere; 3/4-digit `#RGB` shorthand only in CSS-family, so issue/PR refs like `#590` aren't colorized; skipped on big/minified files), rainbow-delimiters (on-theme nested bracket-pair colors; disabled on big/minified files), 0.12 built-ins `:Undotree` and `:DiffTool` (non-git side-by-side file/dir diff), hex.nvim (`<leader>ux` toggle hex view).
- **Persistence** — `persistence.nvim` auto-restores on bare `nvim` (skipping headless, empty sessions, and `nvim <file>` launches, which neither restore nor save), re-attaches TS / LSP / linter on restored buffers. Only window-visible buffers persist (no hidden `badd`). Neotest summary window state persists across sessions. Sessions are scoped per git branch (feature branches keep distinct layouts; main/master share the base session).
- **Width-aware `textwidth`** — `rust` / `python` / `lua` / `elixir` / `ocaml` / `c`-`cpp` / `sql` / `toml` set `textwidth` (the `gq`/`gw` reflow width) to the project formatter's line width, searched upward from its config, else the default — no visual ruler, except `python` (ftplugin draws one at this `textwidth`). See [CUSTOMIZATION](CUSTOMIZATION.md#formatter-width).

## UI

- **Theme** — Catppuccin Mocha retoned to a 2-color **damin** palette: `#98ABCC` (blue) / `#E890B0` (pink). Mirrors [`fish-theme-damin`](https://github.com/miniex/fish-theme-damin) + [`dotfiles.kitty`](https://github.com/miniex/dotfiles.kitty) + [`dotfiles.tmux`](https://github.com/miniex/dotfiles.tmux).
- **lualine** — `✧ … ⋆` sparkle bookends, `✿` mode glyph (swaps to `✎` in visual / operator-pending, briefly `✦` on mode change); `● @x` while a macro is recording; attached LSP client names (refreshed on LSP attach/detach), git diff counts (from gitsigns), an off-default encoding + line-ending indicator (non-`utf-8` / non-`unix` only), and the `searchcount()` match count (cached; refreshed on cursor move / search, skipped above 20000 lines) on the right.
- **bufferline** — pink → mid → blue 3-stop gradient, `surface0` card under active, `▎` left bar + ordinal prefix, `♡` on harpoon-pinned, `●` on modified, uniform 16-char tab width. Tabs open left-to-right (reopening a closed file appends at the tail) and reorder with `<A-S-h>` / `<A-S-l>` (the ordinal follows). Neo-tree / Outline get sidebar offset labels. Lazy-loads on first real file open, so the dashboard isn't preceded by an empty tabline; single-file launches skip it entirely (see Launch modes). `<leader>bp` / `bc` letter-pick a buffer to focus / close.
- **incline** — `⌬` when window is zoomed (alone in tabpage); per-window `✗`/`!` diagnostic count.
- **cursor bloom** — `✿` sign on the current line in mode color (custom autocmd in [`lua/config/cursor-bloom.lua`](../lua/config/cursor-bloom.lua)). Refresh defer skips picker/terminal/chrome buffers.
- **which-key** — hint floats pinned to the bottom row at 85% editor width (centered); height grows with content. Triggers register synchronously on file buffers + `timeoutlen=300` so the first `<leader>` press isn't slow ([#912](https://github.com/folke/which-key.nvim/issues/912) workaround).
- **Floating windows** — every float in the config (LSP hover / signature / diagnostic, Neo-tree, snacks panels, fzf-lua, fff.nvim, blink.cmp menu / signature / docs, fidget, dropbar, bqf, neotest, which-key, harpoon, Mason, lazy, lazygit, checkhealth) shares one look: `✿` flower-cornered border (`✿─✿│✿─✿│`), pink edge, transparent background, centered `✿ title ✿`. Configured in [`lua/config/globals.lua`](../lua/config/globals.lua).
- **flash labels** — damin pink.
- **nvim-scrollbar** — `♥` cursor mark slides smoothly between rows (snaps on large jumps and in big buffers) and heartbeat-pulses while focused (paused after idle, in insert mode, on `FocusLost`, and on chrome buffers like the dashboard / Neo-tree). Handle fades vivid → muted after idle. Git triad in mint/pink/rose plus search hits (`★`); gitsigns gutter + DiagnosticSign share the same palette so both edges agree. Per-keystroke autocmds also skip picker/terminal/prompt buffers so fzf/snacks-picker stay snappy; the cursor mark repaints only on a new scrollbar row (no per-line rebuild on big files).
- **nvim-hlslens** — floats the nearest search match's position at `n` / `N` / `*` / `#`; also drives the scrollbar `★` marks.
- **snacks.scroll** — viewport glides with `outQuad` easing (150ms one-shot, 40ms while held) so key-repeat doesn't queue behind the animation.
- **indent guides** — uniform `┊` dotted guides (snacks.indent), no scope highlight (`[i`/`]i` still jump to scope edges); chunk off.
- **zen** — `<leader>uz` focus mode hides the statusline / bufferline / incline (flower-bordered window).
- **smear-cursor** — fast spring (matched stiffness/trailing, no stretch). Off in picker/terminal floats so the spring doesn't fire per keystroke; 80ms swallow on other float opens skips the `(1,1)` landing jump.
- **cord.nvim** — Discord Rich Presence; gated to local UI (skips headless / SSH).
- **Plus** — edgy (sidebar layout: aerial + neotest-summary → right, trouble/qf/dap + neotest-output → bottom), fidget.

## Modal floats

Big floating UIs (pickers / terminal / lazy / Mason / harpoon / lazygit / Neo-tree / checkhealth) are mutually exclusive — opening one closes the others. Hover, completion, signature, and notifications stack freely on top.

All eight modals share a single 0.85 × 0.85 chrome-aware rectangle defined in [`lua/config/modal-geom.lua`](../lua/config/modal-geom.lua):

- snacks picker / terminal read it via function callbacks
- harpoon / lazy / Mason / lazygit get snapped by a synchronous `FileType` autocmd (no flash because the snap shares a frame with the open)
- fzf-lua uses its own `winopts.on_create` hook (it sets filetype under `eventignore = all` so the FileType aligner misses it)
- Neo-tree's popup `size` / `position` are function callbacks; nui resolves them on every open
- fff.nvim has its own chrome-aware layout that already matches
- checkhealth opens as a native float (`vim.g.health.style`, nvim 0.12) and is dressed at creation by a `modal-floats` decorator — no report tab to flash

A `VimResized` handler in `modal-geom.lua` also re-snaps every open modal, so the rectangle holds when you resize the terminal mid-session (Neo-tree's nui container + inner tree get reflowed together).

See [`lua/config/modal-floats.lua`](../lua/config/modal-floats.lua) for the mutual-exclusion registry.

## Git

- **gitsigns** — gutter signs, hunk staging (`<leader>gh*`, `ghs` toggles stage/unstage), hunk textobject (`ih`/`ah`), inline blame (off by default — toggle `<leader>gtb`), word-diff toggle (`<leader>gtw`), full hunk diff via `<leader>ghp` (centered modal, cursor lands inside) or inline via `<leader>ghi`; `]h`/`[h` hunk nav auto-previews and is `;`/`,`-repeatable (`]H`/`[H` for staged hunks); `<leader>ghQ` sends all-repo hunks to quickfix, `<leader>ghv` views the file at the index.
- **fugitive** — `<leader>gs` status, `<leader>gd` diff, `<leader>gD` 3-way merge diff.
- **lazygit** — `Snacks.lazygit`, auto-themed to the colorscheme. `<leader>gg` open / `<leader>gf` file history / `<leader>gL` log.
- **Diffview** — file / repo / stash history under `<leader>gv*` (current-file history follows renames); `<leader>gvm` reviews the whole branch (working tree vs the default branch).
- **gitgraph.nvim** — in-buffer branch graph. `<leader>gvg` (all branches), `<leader>gvG` (current), `<leader>gvs` (`--since` prompt).
- **advanced-git-search** — search git history by content (`<leader>gH`): which commit changed a line, diff a file against any past commit (fzf-lua picker; diffs open in Diffview).
- **git-conflict** — `]X` / `[X` cycle conflicts, `co` / `ct` / `cb` / `c0` resolve.
- **Auto-refresh** — neo-tree's git column refreshes (debounced) on focus / terminal-exit / save, so external git ops and submodule changes show up without a manual reload.

## Tooling

- **nvim-lint** — runs on save / read (not `InsertLeave`) with a per-buffer 250ms debounce; skips run if you switched away.
- **mason-tool-installer** — single source of truth for Mason installs: LSP servers plus non-LSP tools (shellcheck, golangci-lint, eslint_d, selene, markdownlint, statix, hadolint, sqlfluff, yamllint, …). `auto_update` stays off; a startup toast flags tools with updates (`:MasonToolsUpdate`).
- **DAP** — Rust (rustaceanvim's codelldb) / C-C++ (codelldb) / Python (debugpy) / Go (delve) / Zig (codelldb) / Nim (codelldb) / Elixir (elixir-ls debug adapter) / JS-TS (js-debug-adapter for Node; browser auto-detected from `$PATH` — Chrome, else Firefox; probed lazily, not at startup) / PHP (php-debug-adapter; needs Xdebug) / Bash (bash-debug-adapter / BashDB). C/C++, Zig, Nim, and Rust all resolve codelldb through `lua/config/codelldb.lua`. Persistent breakpoints per-cwd; conditional / hit-condition / log-point breakpoints (`<leader>dB`/`dH`/`dL`); exception breakpoints via `<leader>dE`; reads project `.vscode/launch.json`.
- **neotest** — Python (pytest) / Go (gotestsum) / Elixir (mix) / C/C++ (gtest + ctest: Catch2 / doctest) / Lua (busted + plenary) / Rust (rustaceanvim) / Zig / JS-TS (vitest / jest) / PHP (PHPUnit). Summary window state restored across sessions.
- **Python venv** — basedpyright auto-detects the interpreter (`$VIRTUAL_ENV` / `.venv` / `venv`); `:VenvSelect` (`<leader>cv`) picks another, applied to the running server live.
- **overseer** — task / build runner (`<leader>R*`); auto-detects make / npm / cargo / go / just / cmake templates.
- **nvim-coverage** — test-coverage gutter signs + summary (`<leader>nc` / `nC`, toggle `nv` / clear `nX`); reads lcov / coverage.xml.
- **iron** — send-to-REPL for python / lua / sh / elixir / js-ts (`<leader>i*`).
- **package-info** — npm dependency versions inline in `package.json` (`<leader>cv` / `cu` / `cU` / `cD`).
- **crates.nvim** — Cargo.toml dependency versions inline (`<leader>cv` / `cF` / `cu` / `cU` / `cD`).
- **kulala** — in-editor REST/HTTP client for `.http` / `.rest` files (`<leader>k*`): run / replay / inspect / copy-as-curl.
- **health check** — `:checkhealth` opens as a centered flower modal (not a report tab). `:checkhealth dotfiles` is the in-editor host check (enabled langs → Mason servers, toolchains, DB client, clipboard, terminal/fonts); `./tools/health.sh` is the shell equivalent plus dev-tooling and a config-load smoke test.

## Markdown

- `mdx_analyzer` handles `.mdx`; `marksman` handles `.md`. Highlighting via treesitter; spelling via `typos_lsp`.
- `markdownlint` (nvim-lint) runs a relaxed ruleset — stylistic nags (line length, inline HTML, bare URLs, …) are disabled in `lua/plugins/lsp/lint.lua`; structural / correctness rules stay on.

## Database

- **vim-dadbod-ui** — `<leader>uD` toggles the DB drawer; `:DBUIAddConnection` to register a URL, then browse / query per connection.
- **vim-dadbod-completion** — table / column completion in blink.cmp for `sql` / `mysql` / `plsql` (alongside `sqlls`).
- Needs the engine's client CLI on `$PATH` (`psql` / `mysql` / `sqlite3`).

## Native ui2

- Floating cmdline + messages via `vim._core.ui2.enable()`.
- Opt out with `vim.g.disable_ui2 = true` in `options.lua`.
- `:messages` is aliased to `:Messages`, which renders the history in a centered flower-border modal (ui2's own pager doesn't surface for us).

## Clipboard

Yank → system clipboard auto-routed via `wl-copy` (Wayland), `xclip` (X11), `pbcopy` (macOS), or `clip.exe` (WSL2) — whichever lands on `PATH` first, falling back to OSC52 (works over SSH) when none is present.

## snacks.nvim modules in use

picker · profiler · terminal · dashboard · statuscolumn · notifier · indent · scroll · dim · image · bigfile · scratch · zen · gitbrowse · rename (LSP-aware).

Closing the last named file (`<leader>w` / `<leader>bd` / `:q` / `:wq` / `:x` / `ZZ`) swaps the main window in place for the dashboard — except in a single-file launch (see Launch modes), where it exits instead. On the dashboard `:q` / `:wq` / `:x` / `ZZ` exit nvim; `<leader>w` jumps to a file buffer if any, else exits. `<leader>;` peeks and returns to the alternate on the next press. Persistence quietly swaps dashboard windows out before saving so the session restores cleanly. Footer surfaces a `<leader>qs` hint when a session exists for the cwd.

## Launch modes

How you start Neovim sets the workspace behavior:

- **`nvim`** (no args) — full IDE: tab bar, dashboard, and the cwd session auto-restores on start and saves on exit.
- **`nvim <dir>`** — identical to `cd <dir> && nvim`: chdir's into `<dir>` (dropping the stray dir buffer) and keys the session to `<dir>`, landing on the dashboard or the cwd's restored session (an inaccessible dir falls back to a bare launch).
- **`nvim <file>`** — single-file editor: no tab bar, no dashboard, one buffer at a time (opening another wipes the previous), no session. Closing the file exits Neovim.
- **`nvim a b c…`** (multiple files) — open as tabs in argument order (more can be opened), but the session is left untouched.
- **`nvim dir1 dir2…`** (multiple dirs) — each dir is its own project root; `:next` / `:prev` `:tcd` into whichever is current (cwd / pickers / LSP / session key follow) and show that dir's dashboard. Directory buffers are unlisted, so bufferline carries only the files you open. Sessions are **manual**: `<leader>qs` restores the current dir's, exit saves it (no auto-restore, so `:next` / `:prev` stay intact).

This keeps `nvim <file>` a throwaway editor that never disturbs a directory's saved workspace. Set via `vim.g.single_file` / `vim.g.file_launch` / `vim.g.multi_dir` in `lua/config/globals.lua`.
