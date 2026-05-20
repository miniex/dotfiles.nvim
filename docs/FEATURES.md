# Features

## LSP & Completion

- **Native LSP** — `vim.lsp.config` + `lsp/<server>.lua` discovery; mason-lspconfig handles install/enable.
- **Inlay hints** — toggle per buffer with `<leader>ci`; suppressed automatically during insert mode.
- **Code lens** — enabled on capable servers (gopls, rust-analyzer, lua_ls, ocamllsp, elixir-ls). `BufWritePost` refreshes lens count.
- **Diagnostics** — single config in `lua/plugins/lsp/init.lua`; `tiny-inline-diagnostic.nvim` owns virtual text. Severity-sorted, signs `✗`/`!`/`i`/`?`.
- **Completion** — [blink.cmp](https://github.com/Saghen/blink.cmp) with Rust fuzzy matching. Sources: LSP / snippets (LuaSnip + friendly-snippets) / path / buffer; filtered per filetype (no LSP in `gitcommit` / `gitrebase`, buffer-only in snacks input prompts).
- **LSP restart** — `<leader>cs` for when a server hangs.

## Treesitter

- `main` branch (master is archived and incompatible with 0.12).
- Modules: textobjects (`af`/`if`/`ac`/`ic`/`aa`/`ia` + jumps), sticky context (`treesitter-context`), `nvim-ts-autotag`, `ts-context-commentstring`.
- Custom incremental selection (`gnn` / `gnm` / `gnM`).
- Auto-installs missing parsers on first launch with an early-exit poll.

## Pickers

- **fff.nvim** — Rust-backed file finder. `<leader>ff` for cwd, `<leader>fF` for current dir.
- **snacks.picker** — grep / recent / buffers / help / TODOs. `<leader>fg` / `<leader>fr` / `<leader>fb` / `<leader>fh` / `<leader>ft`.
- **fzf-lua** — git / LSP / lines / snippets / history. `<leader>z*` namespace.
- fff and snacks share the same 0.85 × 0.85 chrome-aware rectangle. The snacks picker's preview overlaps list's right border by 1 column so a single `✿│✿` divider is drawn between them (matches fff's "shared middle flower" effect).

## Editor

- **Files** — neo-tree (floating). `<leader>e` toggle, `<leader>o` reveal current file.
- **Navigation** — flash (`s` / `S`), trouble (`<leader>xx`), aerial (`<leader>cO`), harpoon v2 (`<leader>m*`).
- **Search & replace** — grug-far (`<leader>rr`).
- **Multi-cursor** — multicursor.nvim under `<leader>M*` + `<C-Up>` / `<C-Down>`.
- **Smart inc/dec** — dial.nvim. `<C-a>`/`<C-x>` flips bools, dates, semver, `&&↔||`.
- **Quickfix** — quicker.nvim (editable QF), nvim-bqf (preview), trouble.
- **Misc** — mini.surround (`gs*`), mini.move (`<A-hjkl>` line shuffle), todo-comments, dropbar (winbar), git-conflict, nvim-lightbulb (code-action sign), nvim-colorizer, 0.12 built-in `:Undotree`.
- **Persistence** — `persistence.nvim` auto-restores on bare `nvim`, re-attaches TS / LSP / linter on restored buffers. Neotest summary window state persists across sessions.

## UI

- **Theme** — Catppuccin Mocha retoned to a 2-color **damin** palette: `#98ABCC` (blue) / `#E890B0` (pink). Mirrors [`fish-theme-damin`](https://github.com/miniex/fish-theme-damin) + [`dotfiles.kitty`](https://github.com/miniex/dotfiles.kitty) + [`dotfiles.tmux`](https://github.com/miniex/dotfiles.tmux).
- **lualine** — `✧ … ⋆` sparkle bookends, `✿` mode glyph (swaps to `✎` in visual / operator-pending, briefly `✦` on mode change).
- **bufferline** — pink → mid → blue 3-stop gradient, `surface0` card under active, `▎` left bar + ordinal prefix, `♡` on harpoon-pinned, `●` on modified, uniform 16-char tab width. Neo-tree / Outline get sidebar offset labels.
- **incline** — `⌬` when window is zoomed (alone in tabpage).
- **modicator** — `✿` sign on the current line in mode color.
- **which-key** — hint floats pinned to the bottom row at 85% editor width (centered); height grows with content.
- **Floating windows** — every float in the config (LSP hover / signature / diagnostic, neo-tree, snacks panels, fzf-lua, fff.nvim, blink.cmp menu / signature, dropbar, bqf, neotest, which-key, harpoon, Mason, Lazy, lazygit) shares one look: `✿` flower-cornered border (`✿─✿│✿─✿│`), pink edge, transparent background, centered `✿ title ✿`. Configured in [`lua/config/globals.lua`](../lua/config/globals.lua).
- **flash labels** — damin pink.
- **nvim-scrollbar** — `♥` cursor mark slides smoothly between rows on jumps and heartbeat-pulses while focused (paused on `FocusLost`). Handle fades vivid → muted after idle. Git triad in mint/pink/rose; gitsigns gutter + DiagnosticSign share the same palette so both edges agree.
- **Plus** — edgy (sidebar layout: aerial → right, trouble/qf/dap → bottom), smear-cursor, fidget.

## Modal floats

Big floating UIs (pickers / terminal / lazy / mason / harpoon / lazygit / neo-tree) are mutually exclusive — opening one closes the others. Hover, completion, signature, and notifications stack freely on top.

All seven modals share a single 0.85 × 0.85 chrome-aware rectangle defined in [`lua/config/modal-geom.lua`](../lua/config/modal-geom.lua):

- snacks picker / terminal read it via function callbacks
- harpoon / lazy / mason / lazygit get snapped by a synchronous `FileType` autocmd (no flash because the snap shares a frame with the open)
- fzf-lua uses its own `winopts.on_create` hook (it sets filetype under `eventignore = all` so the FileType aligner misses it)
- neo-tree's popup `size` / `position` are function callbacks; nui resolves them on every open
- fff.nvim has its own chrome-aware layout that already matches

A `VimResized` handler in `modal-geom.lua` also re-snaps every open modal, so the rectangle holds when you resize the terminal mid-session (neo-tree's nui container + inner tree get reflowed together).

See [`lua/config/modal-floats.lua`](../lua/config/modal-floats.lua) for the mutual-exclusion registry.

## Git

- **gitsigns** — gutter signs, hunk staging (`<leader>gh*`), inline blame (`<leader>gtb`), word-level diff highlights inside changed lines.
- **fugitive** — `<leader>gs` status, `<leader>gd` diff, `<leader>gdv` 3-way merge diff.
- **lazygit** — `<leader>gg` full / `<leader>gf` current file / `<leader>gF` filtered.
- **diffview** — file / repo / stash history under `<leader>gv*`.
- **gitgraph.nvim** — in-buffer branch graph. `<leader>gvg` (all branches), `<leader>gvG` (current), `<leader>gvs` (`--since` prompt).
- **git-conflict** — `]X` / `[X` cycle conflicts, `co` / `ct` / `cb` / `c0` resolve.

## Tooling

- **nvim-lint** — per-buffer 250ms debounce, skips run if you switched away.
- **mason-tool-installer** — single source of truth for non-LSP tools (shellcheck, golangci-lint, eslint_d, selene, markdownlint, statix, hadolint, …).
- **DAP** — Rust (rustaceanvim's codelldb) / C-C++ (cpptools) / Python (debugpy) / Go (delve) / Zig (codelldb) / Elixir (elixir-ls debug adapter). Persistent breakpoints per-cwd.
- **neotest** — Python (pytest) / Go (gotestsum) / Elixir (mix) / C/C++ (gtest) / Rust (rustaceanvim). Summary window state restored across sessions.
- **health check** — `./tools/health.sh` reports prereq status.

## Markdown

- `render-markdown.nvim` inline rendering of headings / lists / tables / code blocks.
- `mdx_analyzer` adds MDX support alongside marksman.

## Native UI2

- Floating cmdline + messages via `vim._core.ui2.enable()`.
- Opt out with `vim.g.disable_ui2 = true` in `globals.lua`.

## Clipboard

Yank → system clipboard auto-routed via `wl-copy` (Wayland), `xclip` (X11), `pbcopy` (macOS), or `clip.exe` (WSL2) — whichever lands on `PATH` first.

## snacks.nvim modules in use

picker · profiler · terminal · dashboard · statuscolumn · notifier · indent · scroll · dim · image · bigfile · scratch · zen · gitbrowse · rename (LSP-aware).
