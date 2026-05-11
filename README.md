# Neovim Configuration

Lean, fast, easy on the eyes. Native LSP (`vim.lsp.config`), Rust-backed completion (blink.cmp), aggressive lazy-loading. Lazy.nvim manages plugins, Mason handles the LSP/DAP toolchain.

> **Targets Linux and macOS, in [Kitty](https://sw.kovidgoyal.net/kitty/) terminal.** WSL2 is supported (clipboard bridges to Windows via `clip.exe`). Other terminals work for everything except inline image / GIF / video previews and the Material Design Icons font fallback, which both rely on Kitty.
>
> Pairs well with the companion Kitty config at [`miniex/dotfiles.kitty`](https://github.com/miniex/dotfiles.kitty) — drop it into `~/.config/kitty` for the matching font fallback, theme, and keymaps this setup is tuned against.

![Preview](assets/preview.png)

## Highlights

- **Native LSP, deferred everything** — `vim.lsp.config` + `vim.lsp.enable` directly; Mason install runs on `VimEnter`. Most plugins lazy via `VeryLazy` / `cmd` / `keys` / `ft`
- **Completion & diagnostics** — blink.cmp (Rust fuzzy), inlay hints suppressed during insert, tiny-inline-diagnostic on cursor line with `<leader>cl` to toggle native `virtual_lines`
- **Treesitter** — nvim-treesitter `main` + textobjects, sticky context, ts-autotag (HTML/JSX), ts-context-commentstring
- **Pickers** — fff.nvim (Rust-backed file finder, sub-10ms on huge repos) + snacks.picker for grep / buffers / help / recent + fzf-lua for git / lsp / lines / registers (native `fzf` binary)
- **Editor** — neo-tree (floating popup: `<cr>`/`l` open file in a new tabpage), flash, trouble, which-key, todo-comments, dropbar (winbar breadcrumb with rounded picker + preview), mini.surround (`gs*` prefix to coexist with flash's `s`), persistence (sessions), hex view via `xxd`, aerial (symbols outline panel, LSP + treesitter backed), harpoon v2 (per-project file slots), grug-far (multi-file search/replace with live preview), nvim-bqf (quickfix preview & fzf filter), mini.bufremove (smart buffer close with modified prompt), nvim-colorizer (inline color swatches), git-conflict (merge-conflict navigation)
- **snacks.nvim** — picker, profiler, terminal, dashboard (auto-reopens when the last file buffer is closed), statuscolumn, notifier, indent, scroll, dim, image, bigfile, scope, words
- **Tooling** — nvim-lint, mason-tool-installer, DAP for Rust / C-C++ / Python / Go with `persistent-breakpoints.nvim` (per-cwd breakpoint state survives restarts), neotest with Python / Go / Elixir / C-C++ adapters (Rust tests run via `:RustLsp testables`); formatting is opt-in via `tools/format.sh`, not on save
- **UI** — Cyberdream theme + lualine (LSP symbol breadcrumb via nvim-navic in `lualine_c`) + bufferline (buffer mode, open-order sort, hides `[No Name]` and tabpage indicators) + smear-cursor (tuned to smooth-follow without a trail; the smear pulses only on terminal pane entry) + modicator + fidget
- **Git** — gitsigns, fugitive, lazygit.nvim, diffview (multi-file diff + per-file history), blink-cmp-git commit completions
- **WSL2** clipboard bridge via `clip.exe`

## Language Support

Sorted by language category, then family, then first-appeared.

| Language            | LSP                           | Linter        | Debugger |
|---------------------|-------------------------------|---------------|----------|
| Shell (sh/bash)     | bashls                        | shellcheck    | -        |
| Zsh                 | -                             | zsh -n        | -        |
| Fish                | -                             | fish -n       | -        |
| Assembly            | asm-lsp                       | -             | -        |
| C/C++               | clangd                        | -             | cpptools |
| Go                  | gopls                         | golangci-lint | delve    |
| Rust                | rust-analyzer                 | -             | CodeLLDB |
| Zig                 | zls                           | -             | -        |
| OCaml               | ocamllsp                      | -             | -        |
| Elixir              | elixirls                      | -             | -        |
| Python              | basedpyright + ruff           | ruff (LSP)    | debugpy  |
| Lua                 | lua_ls                        | selene        | -        |
| CSS / HTML          | cssls / html+emmet            | -             | -        |
| Tailwind CSS        | tailwindcss                   | -             | -        |
| JavaScript/TS       | vtsls                         | eslint_d      | -        |
| GraphQL             | graphql                       | -             | -        |
| SQL                 | sqls                          | -             | -        |
| JSON / YAML         | jsonls / yamlls               | -             | -        |
| Protobuf            | buf_ls                        | -             | -        |
| TOML                | taplo                         | -             | -        |
| RON                 | -                             | -             | -        |
| Typst               | tinymist                      | -             | -        |
| Markdown            | marksman                      | markdownlint  | -        |
| MDX                 | marksman + mdx_analyzer       | -             | -        |
| CMake               | neocmake                      | -             | -        |
| Nix                 | nil_ls                        | statix        | -        |
| Dockerfile          | dockerls                      | hadolint      | -        |
| Helm                | helm_ls                       | -             | -        |
| Terraform / HCL     | terraformls                   | tflint        | -        |
| Shaders (WGSL/GLSL) | wgsl-analyzer / glsl_analyzer | -             | -        |
| Just                | just (just-lsp)               | -             | -        |

> Formatting is intentionally not wired into the editor. Run `tools/format.sh` (stylua + shfmt) for the repo's own files; per-language formatting is left to whatever each contributor prefers.

## Setup

### Prerequisites

- **Neovim ≥ 0.12.0**
- `git`, `tar`, `curl`, `xxd`, C compiler, `make`, ripgrep
- A [Nerd Font](https://www.nerdfonts.com/) **plus** [`Symbols Nerd Font Mono`](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip) installed as a fallback — many devicons here are Material Design Icons in the Supplementary PUA (U+F0001–U+F1FFF), which most patched Nerd Fonts don't ship. In Kitty, add `symbol_map U+E000-U+F8FF,U+F0000-U+10FFFD Symbols Nerd Font Mono` to `kitty.conf`
- [`tree-sitter-cli`](https://github.com/tree-sitter/tree-sitter) **≥ 0.26.1** — `cargo install tree-sitter-cli` or OS package manager. **Not npm.**
- Node.js + npm — runtime for npm-based Mason packages (vtsls, eslint_d, marksman, dockerls, tailwindcss-language-server, …)
- Python 3 + pip — required by debugpy
- Go toolchain — required by Mason to install gopls, helm_ls, sqls, terraformls, tflint
- Rust toolchain — required for fff.nvim's binary build (rust-analyzer, tinymist, wgsl-analyzer, glsl_analyzer are Mason-installed)
- Zig toolchain — optional, only if `zig = true`; Mason builds zls from source
- OCaml + opam — optional, only if `ocaml = true`; ocamllsp installs through opam (`opam install ocaml-lsp-server`) rather than Mason
- Erlang + Elixir + mix — optional, only if `elixir = true`; required for elixirls
- [`just`](https://github.com/casey/just) — optional, runner for Justfile recipes (Mason only ships `just-lsp`, not the CLI)
- [lazygit](https://github.com/jesseduffield/lazygit) — optional, for `<leader>gg`
- [`fzf`](https://github.com/junegunn/fzf) — optional, required by fzf-lua (`<leader>z*`)

### Install

**Recommended** — one-shot installer (backs up existing `~/.config/nvim` and `~/.local/share/nvim`, clones the repo, optionally launches the language picker):

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/miniex/dotfiles.nvim/main/install.sh)"
```

**Manual** — if you'd rather wire it up yourself:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
git clone https://github.com/miniex/dotfiles.nvim.git ~/.config/nvim
sh ~/.config/nvim/set-lang.sh   # optional — pick which language plugins to load
nvim
```

Plugins, LSP servers, linters, and DAP adapters install via Mason on first launch. Treesitter parsers download/build asynchronously — re-open files if highlight is briefly missing.

> **If something breaks after `git pull`** — Lazy's compiled spec cache or a stale plugin version is the usual culprit. Nuke local nvim state and restart:
>
> ```bash
> rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
> ```
>
> This wipes plugins, Mason packages, treesitter parsers, undo history, shada, and LSP logs. Plugins and tooling reinstall on next launch.

## Key Bindings

Leader: `<Space>`

### Global
| Key | Mode | Description |
|---|---|---|
| `<C-h/j/k/l>` | N/T | Pane navigation with tmux-style return-to-last (works from terminal mode too; smear animation pulses on entering a terminal pane, then disables itself so typing stays jitter-free) |
| `<leader>h` | N | Clear search highlight |
| `<leader>s` | N | Save |
| `<leader>d` | N/V | Delete without yank |
| `<leader>p` | V | Paste without overwriting register |
| `<` / `>` | V | Indent/outdent (keep selection) |

### Find & Navigate
| Key | Description |
|---|---|
| `<leader>ff` | fff.nvim: find files (Rust-backed, sub-10ms on huge codebases) |
| `<leader>fF` | fff.nvim: find files in current directory |
| `<leader>fg` / `fr` / `fb` / `fh` | snacks.picker: grep / recent / buffers / help |
| `<leader>ft` | TODO comments (snacks.picker) |
| `<leader>z` / `z'` | fzf-lua: builtin menu / resume last picker |
| `<leader>e` / `<leader>o` | Neo-tree: toggle / reveal current file |
| `<cr>` / `l` (in neo-tree) | Open file in a new tabpage (`:tabnew`); folder expand/collapse |
| `s` / `S` (n/x/o) | Flash: jump / treesitter jump |
| `<leader>?` | which-key: buffer-local keymaps |

### fzf-lua (`<leader>z*`)
Native `fzf` binary; complements snacks.picker. `<C-q>` selects all → quickfix; `<C-d>` / `<C-u>` page preview.
| Key | Description |
|---|---|
| `<leader>z` / `z'` | Builtin picker menu / resume last |
| `<leader>zg` / `zc` / `zC` / `zb` | Git: status / buffer commits / project commits / branches |
| `<leader>zs` / `zS` | LSP: document / live workspace symbols |
| `<leader>zd` / `zD` | Diagnostics: buffer / workspace |
| `<leader>zl` / `zk` / `zm` / `zr` | blines / keymaps / marks / registers |
| `<leader>z:` / `z/` | Command / search history |

### Marks (harpoon v2)
Per-project file slots stored under `~/.local/share/nvim/harpoon/`. `<leader>m1`–`<leader>m5` are intentional gaps between buffer-jump `<leader>1`–`<leader>9` (bufferline order) and harpoon slots (manually pinned).
| Key | Description |
|---|---|
| `<leader>ma` / `<leader>mm` | Add current file to harpoon list / toggle quick menu |
| `<leader>mn` / `<leader>mp` | Jump to next / previous slot |
| `<leader>m1` … `<leader>m5` | Jump directly to slot 1–5 |

### Search & Replace (grug-far)
Two-pane buffer with live preview. Inside the grug-far window: `<localleader>r` replace, `<localleader>s` sync edits to disk, `<localleader>q` send results to quickfix.
| Key | Mode | Description |
|---|---|---|
| `<leader>S` | n | Open grug-far at project root |
| `<leader>S` | v | Open grug-far prefilled with the visual selection |
| `<leader>cs` | n | Open grug-far scoped to the current file |

### Session (persistence.nvim)
| Key | Description |
|---|---|
| `<leader>qs` | Restore session for cwd |
| `<leader>qS` | Select session from list |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Don't save current session on exit |

### Profiler (snacks.nvim)
Use `PROF=1 nvim` to profile startup, or these runtime keys:
| Key | Description |
|---|---|
| `<leader>pp` | Toggle profiler |
| `<leader>ps` | Open profiler scratch buffer |
| `<leader>pf` | Pick from captured profile |
| `<leader>ph` | Toggle profiler highlights |

### LSP / Diagnostics
| Key | Description |
|---|---|
| `K` / `<C-k>` (i) | Hover / signature help |
| `gd` / `gr` / `gi` | Definition / references / implementation |
| `<leader>rn` | Rename symbol |
| `<leader>cc` / `<leader>ca` | Diagnostics float / code action |
| `<leader>ci` | Toggle inlay hints |
| `<leader>cd` / `<leader>cl` | Toggle inline diagnostic / multi-line `virtual_lines` |
| `<leader>cL` | Run CodeLens (auto-enabled where the server supports it: rust-analyzer, gopls, elixir-ls, ocamllsp, jdtls, …) |
| `<leader>cO` / `<leader>cN` | Aerial: toggle symbols outline / toggle outline nav window |
| `[o` / `]o` | Aerial: previous / next symbol in current buffer |
| `<leader>cm` | Open Mason |
| `<leader>xx/xd/xs/xq/xl` | Trouble: diagnostics / buf only / symbols / qf / loclist |
| `<leader>xt` / `<leader>xT` | Trouble: TODOs / TODO+FIX+FIXME |
| `[q` / `]q` | Prev / next item (Trouble + qf fallback) |
| `[t` / `]t` | Prev / next TODO comment |

### Treesitter Textobjects & Context
| Key | Mode | Description |
|---|---|---|
| `af` / `if` | x/o | Function (outer / inner) |
| `ac` / `ic` | x/o | Class (outer / inner) |
| `aa` / `ia` | x/o | Parameter / argument (outer / inner) |
| `ai` / `ii` | x/o | Conditional (outer / inner) |
| `al` / `il` | x/o | Loop (outer / inner) |
| `a/` / `i/` | x/o | Comment (outer / inner) |
| `a=` / `i=` | x/o | Assignment (outer / inner) |
| `am` / `im` | x/o | Call (outer / inner) |
| `aB` / `iB` | x/o | Block (outer / inner) — capital `B` because `b` is the word-back motion |
| `aS` | x/o | Statement (outer) |
| `]f` / `[f` | n/x/o | Next / prev function start |
| `]F` / `[F` | n/x/o | Next / prev function end |
| `]c` / `[c` | n/x/o | Next / prev class start |
| `]a` / `[a` | n/x/o | Next / prev parameter |
| `<leader>a` / `<leader>A` | n | Swap parameter with next / prev |
| `gnn` | n | Incremental selection: select current treesitter node |
| `gnm` / `gnM` | x | Expand to parent node / shrink back through the expansion stack |
| `<leader>uc` | n | Toggle treesitter context (sticky function header) |
| `<leader>uC` | n | Toggle nvim-colorizer (inline color swatches) |
| `[x` | n | Jump to context start |

### Winbar Breadcrumb (dropbar)
Picker uses rounded border + preview-on-cursor. Inside the picker: `q`/`<Esc>` close, `h` go to parent menu, `l` open the entry under the cursor.
| Key | Description |
|---|---|
| `<leader>uw` | Pick segment to jump to |
| `[w` / `]w` | Jump to context start / next context |

### Git
| Key | Description |
|---|---|
| `<leader>gs/gb/gd/gl/gc/gp/gP` | Fugitive: status/blame/diff/log/commit/push/pull |
| `<leader>gg` / `gf` / `gF` / `gL` | LazyGit: full / current file / filter file / filter all |
| `<leader>gvo` / `gvc` / `gvr` | Diffview: open / close / refresh |
| `<leader>gvf` / `gvF` / `gvh` | Diffview file history: current file / repo / stash |
| `[h` / `]h` | Prev / next hunk |
| `<leader>ghs/r/S/u/R/p/i/b/d/D` | Stage / reset / stage-buf / undo-stage / reset-buf / preview / inline-preview / blame-line / diff / diff~ |
| `<leader>gtb` / `<leader>gtd` | Toggle line blame / show deleted |
| `<leader>gxq` | git-conflict: send all conflicts to quickfix |
| `[X` / `]X` | Previous / next merge conflict (git-conflict.nvim) |
| `co` / `ct` / `cb` / `c0` | Inside a conflict block: choose ours / theirs / both / none |

### Debugger (DAP)
| Key | Description |
|---|---|
| `<leader>db` / `dB` / `dX` | Toggle / conditional / clear-all breakpoint (persisted per-cwd via persistent-breakpoints.nvim) |
| `<leader>dc` / `dC` | Continue / run-to-cursor |
| `<leader>di` / `dO` / `do` | Step into / over / out |
| `<leader>dg` / `dj` / `dk` | Go to line (no execute) / Down / Up frame |
| `<leader>dl/dr/dp/dt/ds/du` | Last / REPL / pause / terminate / session / toggle UI |
| `<leader>dGt` / `<leader>dGl` | Go: debug nearest test / debug last test (nvim-dap-go) |
| `<leader>dPt` / `<leader>dPc` | Python: debug test method / class |

### Test (neotest)
Adapters: Python (pytest), Go (gotestsum), Elixir (mix), C/C++ (gtest). Rust tests are handled by `:RustLsp testables` (rustaceanvim). Uses `<leader>n*` because `<leader>t` is the terminal toggle.
| Key | Description |
|---|---|
| `<leader>nr` / `nf` / `nA` | Run nearest / file / all (cwd) |
| `<leader>nl` / `nd` / `nx` | Run last / debug nearest (DAP) / stop |
| `<leader>ns` / `no` / `nO` / `nw` | Toggle summary / show output / output panel / watch file |
| `]T` / `[T` | Next / prev failed test (capital `T` to coexist with todo-comments' `]t`/`[t`) |

### Surround (mini.surround)
Uses `gs*` because flash owns `s` in normal/visual/operator-pending modes.
| Key | Description | Example |
|---|---|---|
| `gsa{motion}{char}` | Add surrounding | `gsaiw"` → wrap inner word in `"` |
| `gsd{char}` | Delete surrounding | `gsd"` → strip `"` |
| `gsr{old}{new}` | Replace surrounding | `gsr"'` → swap `"` for `'` |
| `gsf{char}` / `gsF{char}` | Find right / left surrounding | |
| `gsh{char}` | Highlight surrounding | |
| `gsn` | Update `n_lines` (search range) | |

### Terminal & Buffers (snacks.nvim + bufferline)
Inside the toggle terminal, `$EDITOR` / `$VISUAL` / `$GIT_EDITOR` resolve to `scripts/term-bin/nvim`, which forwards to the parent Neovim via `--server $NVIM --remote-wait` — so `git commit` and other editor-invoking tools open a split in the outer instance instead of spawning a nested Neovim.

| Key | Description |
|---|---|
| `<leader>t` (n/t) | Toggle terminal (centered floating window, 85% × 85%) |
| `<C-x>` | Hide terminal |
| `<leader>w` | Smart buffer delete (closing the last file buffer drops you back to the dashboard) |
| `<leader>bd` / `<leader>bD` | mini.bufremove: delete buffer preserving layout (prompts on modified) / force-delete |
| `<leader>1` … `<leader>9` | Jump to buffer by bufferline position |
| `[b` / `]b` | Previous / next buffer (bufferline order — open order; reopened buffers append to the end) |
| `<leader>cn` / `<leader>un` | Notification history / dismiss all |
| `]]` / `[[` | LSP word: next / previous reference |

### Language-specific
| Key | Description |
|---|---|
| `<leader>ch` | C/C++: switch source ↔ header |
| `<leader>cR` / `<leader>cD` | Rust: code action / debuggables (rustaceanvim) |

### Hex (hex.nvim — requires `xxd`)
`:HexToggle`, `:HexDump`, `:HexAssemble`, or `nvim -b <file>`.

### Completion (insert mode)
`<Tab>` / `<S-Tab>` next/prev · `<C-Space>` trigger · `<CR>` confirm · `<C-e>` close · `<C-f>` / `<C-S-f>` scroll docs.

## Customization

- **Disable languages you don't use** — run `sh ~/.config/nvim/set-lang.sh` for an interactive picker (↑/↓, space to toggle, enter to save), or hand-edit `lua/config/langs_local.lua` (gitignored) directly. Either way it overrides the defaults in `lua/config/langs.lua` per-machine without polluting upstream.
- **New language** — add a file under `lua/plugins/lang/` extending `nvim-lspconfig` `servers` (auto-installed via mason-lspconfig's `ensure_installed`, populated dynamically), then add the module name to `lua/config/langs.lua` so it gets imported. Linters live in `lua/plugins/lsp/lint.lua` (extend `opts.linters_by_ft`), treesitter parsers in `lua/plugins/editor/treesitter.lua`. Non-LSP tools (linters, DAP adapters) install through `WhoIsSethDaniel/mason-tool-installer.nvim` — extend its `opts.ensure_installed`. `python.lua` shows the LSP + DAP wiring.
- **User snippets** — drop Lua snippet files in `~/.config/nvim/snippets/` (loaded via `luasnip.loaders.from_lua`). `all.lua` applies to every filetype; `<filetype>.lua` is filetype-scoped. friendly-snippets continues to load VSCode JSON in parallel. Shipped templates: `all.lua` (`date`, `datetime`), `lua.lua` (`req`, `preq`, `lf`, `mod`), `python.lua` (`main`, `dcls`, `deft`, `bp`), `rust.lua` (`der`, `tst`, `mt`, `imp`), `typescript.lua` (`imp`, `impd`, `ecf`, `intf`, `tya`, `afn`, `desc`, `cl`), `javascript.lua` (`imp`, `impd`, `req`, `ecf`, `afn`, `desc`, `cl`), `go.lua` (`main`, `iferr`, `iferrf`, `fn`, `meth`, `st`, `intf`, `tst`, `tstt`), `sh.lua` (`sh`, `fn`, `if`, `for`, `case`, `die`), `c.lua` (`inc`, `incl`, `guard`, `main`, `fn`, `ts`, `for`), `cpp.lua` (`inc`, `incl`, `main`, `cls`, `ns`, `for`, `mu`, `ms`), `markdown.lua` (`code`, `link`, `img`, `tbl`, `fm`, `task`, `det`), `yaml.lua` (`gha`, `step`, `svc`, `anc`). `tsx`/`jsx` inherit from `typescript`/`javascript`; `bash`/`zsh` inherit from `sh`.
- **Test adapters** — `lua/plugins/lsp/neotest.lua` registers neotest-python, neotest-golang, neotest-elixir, neotest-gtest; add new adapters to its `dependencies` and `setup({ adapters = ... })` list.
- **Theme** — `lua/plugins/ui/themes.lua`. Cyberdream highlights are compiled to `~/.cache/nvim/cyberdream_cache.json` (`cache = true`); the cache rebuilds automatically when this file is saved, so colour tweaks just work.
- **Keymaps** — `lua/config/keymaps.lua`, helper `map(lhs, rhs, mode, desc)`.
- **Autocmds** — `lua/config/autocmds.lua` (treesitter attach, WSL2 clipboard, file reload, end-of-buffer tilde hide).
- **Diagnostic styling** — `lua/plugins/lsp/init.lua` `config()` (signs, virtual_text, float border). Loaded only on first buffer (`BufReadPre`) so it doesn't cost startup time.
- **Contributor tools** — `tools/format.sh` (stylua + shfmt) and `tools/lint.sh` (stylua check, lua-language-server diagnostics, shfmt diff, shellcheck). See [CONTRIBUTING.md](CONTRIBUTING.md).

## Contributing

PRs welcome. Before opening one:

- Run `./tools/format.sh` and `./tools/lint.sh` — both must pass clean.
- Follow the commit prefix convention (`feat:`, `fix:`, `refactor:`, `docs:`, …, all lowercase).

Full details in [CONTRIBUTING.md](CONTRIBUTING.md).

## Troubleshooting

| Issue | Check |
|---|---|
| LSP not attaching | `:Mason`, `:LspInfo`, `:LspLog` |
| Lint not running | linter on `$PATH`, see `lua/plugins/lsp/lint.lua` |
| Mason tools missing | `:MasonToolsUpdate`, then `:Mason` to confirm |
| `<leader>ff` not working | fff.nvim's binary failed to download/build; run `:Lazy build fff.nvim` (Rust toolchain on `$PATH`) |
| Sessions not loading | `:lua require('persistence').list()` to inspect; `<leader>qS` to pick |
| Profiling startup | `PROF=1 nvim`, then `<leader>pp` to toggle, `<leader>pf` to pick captured frames |
| Vim plugin needs python3/ruby/perl/node provider | All four are disabled by default in `lua/config/globals.lua` for startup speed — remove the `loaded_*_provider` line for the one you need |
| Treesitter errors | `:checkhealth nvim-treesitter`; `tree-sitter --version` ≥ 0.26.1 (not the npm build) |
| Theme tweaks not showing up | `rm ~/.cache/nvim/cyberdream_cache.json` and restart — the autocmd usually invalidates it on save, but a stale cache from before the option was enabled needs a one-shot wipe |

> The `master` branch of nvim-treesitter is archived and incompatible with Neovim 0.12; this config is pinned to `main`.

## License

[MIT](LICENSE) © 2024-2026 Han Damin — applies to all code in this repository.

**Exception:** `assets/dashboard_sticker.ansi` and `assets/preview.png` are derived from a copyrighted emoji of a copyrighted character (the screenshot visually embeds the same artwork). They are **not** covered by the MIT license. All rights reserved by Han Damin <miniex@daminstudio.net>. If you fork or redistribute this repo, you must remove both files before publishing. See [`assets/LICENSE`](assets/LICENSE) for full terms.
