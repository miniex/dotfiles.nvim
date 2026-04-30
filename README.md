# Neovim Configuration

Modular, fast-startup, LSP-first Neovim setup. Lazy.nvim for plugins, Mason for LSP/DAP toolchain.

> **Targets Linux and macOS, in [Kitty](https://sw.kovidgoyal.net/kitty/) terminal.** WSL2 is supported (clipboard bridges to Windows via `clip.exe`). Other terminals work for everything except inline image / GIF / video previews and the Material Design Icons font fallback, which both rely on Kitty.

## Highlights

- **Aggressive lazy-loading** — most plugins deferred via `VeryLazy` / `cmd` / `keys`; only colorscheme, treesitter, and snacks.nvim load eagerly. Treesitter parser installs deferred via `vim.schedule` so they never block startup
- **Native LSP** — `vim.lsp.config` + `mason-lspconfig.automatic_enable` (no lspconfig framework overhead)
- LSP + completion (blink.cmp, Rust backend; lazydev for Lua), inlay hints auto-enabled per buffer
- Treesitter highlighting via nvim-treesitter `main` + built-in `vim.treesitter`
- DAP debugging (Rust / C-C++ / Python)
- Telescope, neo-tree, which-key, flash, trouble, todo-comments
- Binary file hex view/edit via `xxd` (hex.nvim) — `:HexToggle`, `:HexDump`, `:HexAssemble`, or `nvim -b <file>`
- snacks.nvim bundle: terminal (anchored to file window), dashboard, statuscolumn, notifier, scroll, dim, image, bufdelete, words, bigfile, indent, input, quickfile, scope
- Cyberdream theme + lualine + smear-cursor + modicator + fidget + undo-glow
- Format-on-save (conform.nvim), async lint (nvim-lint)
- Git: gitsigns, fugitive, lazygit.nvim, blink-cmp-git commit completions
- WSL2 clipboard integration via `clip.exe`

## Language Support

| Language      | LSP                 | Formatter        | Debugger |
|---------------|---------------------|------------------|----------|
| Rust          | rust-analyzer       | rustfmt          | CodeLLDB |
| C/C++         | clangd              | clang-format     | cpptools |
| JavaScript/TS | vtsls               | prettierd        | -        |
| Python        | basedpyright + ruff | ruff (via LSP)   | debugpy  |
| Lua           | lua_ls              | stylua           | -        |
| JSON / YAML   | jsonls / yamlls     | prettierd        | -        |
| Markdown      | marksman            | prettierd        | -        |
| CMake         | neocmake            | cmake_format     | -        |
| TOML          | taplo               | taplo            | -        |
| CSS / HTML    | cssls / html+emmet  | prettierd        | -        |
| RON           | -                   | rustfmt          | -        |

Linters: `eslint_d` (JS/TS), `markdownlint`, `ruff` (Python via LSP).

## Setup

### Prerequisites

- **Neovim ≥ 0.12.0**
- `git`, `tar`, `curl`, `xxd`, C compiler, `make`, ripgrep, a [Nerd Font](https://www.nerdfonts.com/)
- [`tree-sitter-cli`](https://github.com/tree-sitter/tree-sitter) **≥ 0.26.1** — `cargo install tree-sitter-cli` or OS package manager. **Not npm.**
- Node.js + npm (LSP servers, prettierd, eslint_d)
- Python 3 (linters/formatters)
- Rust toolchain (rustfmt, rust-analyzer)
- [lazygit](https://github.com/jesseduffield/lazygit) — optional, for `<leader>gg`

### Install

```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
git clone <repo> ~/.config/nvim
nvim
```

Plugins, LSP servers, and DAP adapters install on first launch. Treesitter parsers download/build asynchronously — re-open files if highlight is briefly missing.

## Key Bindings

Leader: `<Space>`

### Global
| Key | Mode | Description |
|---|---|---|
| `<C-h/j/k/l>` | N | Pane navigation |
| `<leader>h` | N | Clear search highlight |
| `<leader>s` | N | Save |
| `<leader>d` | N/V | Delete without yank |
| `<leader>p` | V | Paste without overwriting register |
| `<` / `>` | V | Indent/outdent (keep selection) |

### Find & Navigate
| Key | Description |
|---|---|
| `<leader>ff` / `fg` / `fr` / `fb` / `fh` | Telescope: files / grep / recent / buffers / help |
| `<leader>ft` | TODO comments (Telescope) |
| `<leader>e` / `<leader>o` | Neo-tree: toggle / reveal current file |
| `s` / `S` (n/x/o) | Flash: jump / treesitter jump |
| `<leader>?` | which-key: buffer-local keymaps |

### LSP / Diagnostics
| Key | Description |
|---|---|
| `K` / `<C-k>` (i) | Hover / signature help |
| `gd` / `gr` / `gi` | Definition / references / implementation |
| `<leader>rn` | Rename symbol |
| `<leader>cc` / `<leader>ca` | Diagnostics float / code action |
| `<leader>ci` | Toggle inlay hints |
| `<leader>cf` | Format buffer |
| `<leader>cm` | Open Mason |
| `<leader>xx/xd/xs/xq/xl` | Trouble: diagnostics / buf only / symbols / qf / loclist |
| `<leader>xt` / `<leader>xT` | Trouble: TODOs / TODO+FIX+FIXME |
| `[q` / `]q` | Prev / next item (Trouble + qf fallback) |
| `[t` / `]t` | Prev / next TODO comment |

### Git
| Key | Description |
|---|---|
| `<leader>gs/gb/gd/gl/gc/gp/gP` | Fugitive: status/blame/diff/log/commit/push/pull |
| `<leader>gg` / `gf` / `gF` / `gL` | LazyGit: full / current file / filter file / filter all |
| `[h` / `]h` | Prev / next hunk |
| `<leader>ghs/r/S/u/R/p/i/b/d/D` | Stage / reset / stage-buf / undo-stage / reset-buf / preview / inline-preview / blame-line / diff / diff~ |
| `<leader>gtb` / `<leader>gtd` | Toggle line blame / show deleted |

### Debugger (DAP)
| Key | Description |
|---|---|
| `<leader>db` / `dB` | Toggle / conditional breakpoint |
| `<leader>dc` / `dC` | Continue / run-to-cursor |
| `<leader>di` / `dO` / `do` | Step into / over / out |
| `<leader>dg` / `dj` / `dk` | Go to line (no execute) / Down / Up frame |
| `<leader>dl/dr/dp/dt/ds/du` | Last / REPL / pause / terminate / session / toggle UI |
| `<leader>dPt` / `<leader>dPc` | Python: debug test method / class |

### Terminal & Buffers (snacks.nvim)
| Key | Description |
|---|---|
| `<leader>t` (n/t) | Toggle terminal (45% bottom split, anchored to file window) |
| `<C-x>` | Hide terminal |
| `<leader>bd` | Smart buffer delete |
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

- **New language** — add a file under `lua/plugins/lang/` extending `nvim-lspconfig` `servers` (auto-installs via Mason). Formatters live in `lua/plugins/lsp/conform.lua`, linters in `lua/plugins/lsp/lint.lua`, treesitter parsers in `lua/plugins/editor/treesitter.lua`. `python.lua` shows the LSP + DAP wiring.
- **Theme** — `lua/plugins/ui/themes.lua`.
- **Keymaps** — `lua/config/keymaps.lua`, helper `map(lhs, rhs, mode, desc)`.

## Troubleshooting

| Issue | Check |
|---|---|
| LSP not attaching | `:Mason`, `:LspInfo`, `:LspLog` |
| Format not running | `:ConformInfo`, formatter on `$PATH` |
| Lint not running | linter on `$PATH`, see `lua/plugins/lsp/lint.lua` |
| Treesitter errors | `:checkhealth nvim-treesitter`; `tree-sitter --version` ≥ 0.26.1 (not the npm build) |

> The `master` branch of nvim-treesitter is archived and incompatible with Neovim 0.12; this config is pinned to `main`.

## License

[MIT](LICENSE) © 2026 Han Damin.
