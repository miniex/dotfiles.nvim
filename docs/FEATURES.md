# Features

## LSP & Completion

- **Native LSP** — `vim.lsp.config` + `lsp/<server>.lua` discovery; mason-lspconfig installs, the config enables servers itself (gated by enabled langs + executable presence). Workspace root anchors on language manifests, `.git` as fallback.
- **Inlay hints** — toggle per buffer with `<leader>ci`; suppressed automatically during insert mode.
- **CodeLens** — enabled on capable servers (gopls, rust-analyzer, lua_ls, ocamllsp, elixir-ls); refreshes on edit, paused during insert mode (like inlay hints).
- **LSP folding** — capable servers fold via `vim.lsp.foldexpr`; treesitter folds everything else.
- **Navigation** — `gd` / `gr` / `gi` / `gy` open an fzf-lua picker (auto-jumps on a single result).
- **Formatting** — `<leader>cf` runs `vim.lsp.buf.format` (native LSP; no formatter plugin).
- **Semantic tokens** — toggle per buffer with `<leader>uy` (e.g. when they clash with treesitter highlight).
- **Document colors** — LSP color swatches via native `vim.lsp.document_color` on any capable server (tailwindcss, cssls, …); colorizer still owns hex.
- **Diagnostics** — single config in `lua/plugins/lsp/init.lua`; `tiny-inline-diagnostic.nvim` owns virtual text. Severity-sorted, signs `✗`/`!`/`i`/`?`.
- **Completion** — [blink.cmp](https://github.com/Saghen/blink.cmp) with Rust fuzzy matching + inline ghost-text preview. Sources: LSP / snippets (LuaSnip + friendly-snippets) / path / buffer; filtered per filetype (no LSP in `gitcommit` / `gitrebase`, buffer-only in snacks input prompts). Cmdline completion on `:` (commands / paths) and `/` `?` (search).
- **LSP restart** — `<leader>cs` for when a server hangs.

## Treesitter

- `main` branch (master is archived and incompatible with 0.12).
- Modules: textobjects (`af`/`if`/`ac`/`ic`/`aa`/`ia` + jumps), sticky context (`treesitter-context`), `nvim-ts-autotag`, `ts-context-commentstring`.
- Custom incremental selection (`gnn` / `gnm` / `gnM`).
- Auto-installs missing parsers on first launch with an early-exit poll.
- Big-file guard — skips highlight/indent on files >1 MB or with a >2000-char first line (snacks.bigfile handles >1.5 MB).

## Pickers

- **fff.nvim** — Rust-backed file finder. `<leader>ff` for cwd, `<leader>fF` for current dir.
- **snacks.picker** — grep / recent / buffers / help / TODOs. `<leader>fg` / `<leader>fr` / `<leader>fb` / `<leader>fh` / `<leader>ft`.
- **fzf-lua** — git / LSP / grep / lines / snippets / history. `<leader>z*` namespace.
- fff and snacks share the same 0.85 × 0.85 chrome-aware rectangle. The snacks picker's preview overlaps the list's right border by 1 column so a single `✿│✿` divider is drawn between them (matches fff's "shared middle flower" effect).

## Editor

- **Files** — Neo-tree (floating). `<leader>e` toggle, `<leader>o` reveal current file. Directory rows show recursive total size instead of the default `-`.
- **Navigation** — flash (`s` / `S`), Trouble (`<leader>xx`), aerial (`<leader>cO`), harpoon v2 (`<leader>m*`).
- **Search & replace** — grug-far (`<leader>rr`).
- **Multi-cursor** — multicursor.nvim under `<leader>M*` + `<C-Up>` / `<C-Down>`.
- **Smart inc/dec** — dial.nvim. `<C-a>`/`<C-x>` flips bools, dates, semver, hex colors, `&&↔||` (plus `let↔const` in JS/TS and headers in markdown).
- **Quickfix** — quicker.nvim (editable QF), nvim-bqf (preview), Trouble (`auto_close` on jump, main-window preview).
- **Misc** — mini.surround (`gs*`), mini.ai (`a`/`i` brackets/quotes/tags + `an`/`aL` next/last), mini.move (`<A-hjkl>` line shuffle), todo-comments, dropbar (winbar), git-conflict, nvim-lightbulb (code-action sign), nvim-colorizer (6/8-digit hex everywhere; 3/4-digit `#RGB` shorthand only in CSS-family, so issue/PR refs like `#590` aren't colorized), 0.12 built-in `:Undotree`.
- **Persistence** — `persistence.nvim` auto-restores on bare `nvim` (skipping headless and empty sessions), re-attaches TS / LSP / linter on restored buffers. Only window-visible buffers persist (no hidden `badd`). Neotest summary window state persists across sessions.
- **Width ruler** — `rust` / `python` / `lua` / `elixir` / `ocaml` / `c`-`cpp` / `sql` / `toml` draw a `colorcolumn` at the project formatter's line width, searched upward from its config, else the default. See [CUSTOMIZATION](CUSTOMIZATION.md#formatter-width-ruler).

## UI

- **Theme** — Catppuccin Mocha retoned to a 2-color **damin** palette: `#98ABCC` (blue) / `#E890B0` (pink). Mirrors [`fish-theme-damin`](https://github.com/miniex/fish-theme-damin) + [`dotfiles.kitty`](https://github.com/miniex/dotfiles.kitty) + [`dotfiles.tmux`](https://github.com/miniex/dotfiles.tmux).
- **lualine** — `✧ … ⋆` sparkle bookends, `✿` mode glyph (swaps to `✎` in visual / operator-pending, briefly `✦` on mode change); `● @x` while a macro is recording; attached LSP client names and `searchcount()` on the right.
- **bufferline** — pink → mid → blue 3-stop gradient, `surface0` card under active, `▎` left bar + ordinal prefix, `♡` on harpoon-pinned, `●` on modified, uniform 16-char tab width. Neo-tree / Outline get sidebar offset labels. Lazy-loads on first real file open, so the dashboard isn't preceded by an empty tabline.
- **incline** — `⌬` when window is zoomed (alone in tabpage).
- **cursor bloom** — `✿` sign on the current line in mode color (custom autocmd in [`lua/config/cursor-bloom.lua`](../lua/config/cursor-bloom.lua)). Refresh defer skips picker/terminal/chrome buffers.
- **which-key** — hint floats pinned to the bottom row at 85% editor width (centered); height grows with content. Triggers register synchronously + `timeoutlen=300` so the first `<leader>` press isn't slow ([#912](https://github.com/folke/which-key.nvim/issues/912) workaround).
- **Floating windows** — every float in the config (LSP hover / signature / diagnostic, Neo-tree, snacks panels, fzf-lua, fff.nvim, blink.cmp menu / signature / docs, fidget, dropbar, bqf, neotest, which-key, harpoon, Mason, lazy, lazygit) shares one look: `✿` flower-cornered border (`✿─✿│✿─✿│`), pink edge, transparent background, centered `✿ title ✿`. Configured in [`lua/config/globals.lua`](../lua/config/globals.lua).
- **flash labels** — damin pink.
- **nvim-scrollbar** — `♥` cursor mark slides smoothly between rows (snaps on large jumps) and heartbeat-pulses while focused (paused in insert mode, on `FocusLost`, and on chrome buffers like the dashboard / Neo-tree). Handle fades vivid → muted after idle. Git triad in mint/pink/rose; gitsigns gutter + DiagnosticSign share the same palette so both edges agree. Per-keystroke autocmds also skip picker/terminal/prompt buffers so fzf/snacks-picker stay snappy.
- **snacks.scroll** — viewport glides with `outQuad` easing (150ms one-shot, 40ms while held) so key-repeat doesn't queue behind the animation.
- **smear-cursor** — fast spring (matched stiffness/trailing, no stretch). Off in picker/terminal floats so the spring doesn't fire per keystroke; 80ms swallow on other float opens skips the `(1,1)` landing jump.
- **Plus** — edgy (sidebar layout: aerial + neotest-summary → right, trouble/qf/dap + neotest-output → bottom), fidget.

## Modal floats

Big floating UIs (pickers / terminal / lazy / Mason / harpoon / lazygit / Neo-tree) are mutually exclusive — opening one closes the others. Hover, completion, signature, and notifications stack freely on top.

All seven modals share a single 0.85 × 0.85 chrome-aware rectangle defined in [`lua/config/modal-geom.lua`](../lua/config/modal-geom.lua):

- snacks picker / terminal read it via function callbacks
- harpoon / lazy / Mason / lazygit get snapped by a synchronous `FileType` autocmd (no flash because the snap shares a frame with the open)
- fzf-lua uses its own `winopts.on_create` hook (it sets filetype under `eventignore = all` so the FileType aligner misses it)
- Neo-tree's popup `size` / `position` are function callbacks; nui resolves them on every open
- fff.nvim has its own chrome-aware layout that already matches

A `VimResized` handler in `modal-geom.lua` also re-snaps every open modal, so the rectangle holds when you resize the terminal mid-session (Neo-tree's nui container + inner tree get reflowed together).

See [`lua/config/modal-floats.lua`](../lua/config/modal-floats.lua) for the mutual-exclusion registry.

## Git

- **gitsigns** — gutter signs, hunk staging (`<leader>gh*`), hunk textobject (`ih`/`ah`), inline blame (`<leader>gtb`), full hunk diff via `<leader>ghp` (centered modal, cursor lands inside).
- **fugitive** — `<leader>gs` status, `<leader>gd` diff, `<leader>gdv` 3-way merge diff.
- **lazygit** — `Snacks.lazygit`, auto-themed to the colorscheme. `<leader>gg` open / `<leader>gf` file history / `<leader>gL` log.
- **Diffview** — file / repo / stash history under `<leader>gv*`.
- **gitgraph.nvim** — in-buffer branch graph. `<leader>gvg` (all branches), `<leader>gvG` (current), `<leader>gvs` (`--since` prompt).
- **git-conflict** — `]X` / `[X` cycle conflicts, `co` / `ct` / `cb` / `c0` resolve.

## Tooling

- **nvim-lint** — runs on save / read (not `InsertLeave`) with a per-buffer 250ms debounce; skips run if you switched away.
- **mason-tool-installer** — single source of truth for non-LSP tools (shellcheck, golangci-lint, eslint_d, selene, markdownlint, statix, hadolint, sqlfluff, yamllint, …).
- **DAP** — Rust (rustaceanvim's codelldb) / C-C++ (codelldb) / Python (debugpy) / Go (delve) / Zig (codelldb) / Elixir (elixir-ls debug adapter) / JS-TS (js-debug-adapter, Node). C/C++ and Zig share the codelldb resolver in `lua/config/codelldb.lua`. Persistent breakpoints per-cwd; reads project `.vscode/launch.json`.
- **neotest** — Python (pytest) / Go (gotestsum) / Elixir (mix) / C/C++ (gtest) / Lua (busted) / Rust (rustaceanvim) / Zig / JS-TS (vitest). Summary window state restored across sessions.
- **health check** — `./tools/health.sh` reports prereq status, enabled languages + missing Mason LSP servers, and runs a headless config-load smoke test.

## Markdown

- `render-markdown.nvim` inline rendering of headings / lists / tables / code blocks.
- `mdx_analyzer` handles `.mdx`; `marksman` handles `.md`; `harper_ls` adds prose grammar / spell on markdown.

## Database

- **vim-dadbod-ui** — `<leader>uD` toggles the DB drawer; `:DBUIAddConnection` to register a URL, then browse / query per connection.
- **vim-dadbod-completion** — table / column completion in blink.cmp for `sql` / `mysql` / `plsql` (alongside `sqls`).
- Needs the engine's client CLI on `$PATH` (`psql` / `mysql` / `sqlite3`).

## Native ui2

- Floating cmdline + messages via `vim._core.ui2.enable()`.
- Opt out with `vim.g.disable_ui2 = true` in `globals.lua`.
- `:messages` is aliased to `:Messages`, which renders the history in a centered flower-border modal (ui2's own pager doesn't surface for us).

## Clipboard

Yank → system clipboard auto-routed via `wl-copy` (Wayland), `xclip` (X11), `pbcopy` (macOS), or `clip.exe` (WSL2) — whichever lands on `PATH` first, falling back to OSC52 (works over SSH) when none is present.

## snacks.nvim modules in use

picker · profiler · terminal · dashboard · statuscolumn · notifier · indent · scroll · dim · image · bigfile · scratch · zen · gitbrowse · rename (LSP-aware).

Closing the last named file (`<leader>w` / `<leader>bd` / `:q` / `:wq` / `:x` / `ZZ`) swaps the main window in place for the dashboard. On the dashboard `:q` / `:wq` / `:x` / `ZZ` exit nvim; `<leader>w` jumps to a file buffer if any, else exits. `<leader>;` peeks and returns to the alternate on the next press. Persistence quietly swaps dashboard windows out before saving so the session restores cleanly. Footer surfaces a `<leader>qs` hint when a session exists for the cwd.
