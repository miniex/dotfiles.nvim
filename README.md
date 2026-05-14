# Neovim Configuration

Lean, fast, easy on the eyes. Native LSP via `lsp/<server>.lua` discovery, Rust-backed completion (blink.cmp), aggressive lazy-loading.

> **Targets Linux/macOS in [Kitty](https://sw.kovidgoyal.net/kitty/).** WSL2 supported via `clip.exe`. Other terminals work except inline image previews and Material Design Icons fallback.
>
> Pairs with [`miniex/dotfiles.kitty`](https://github.com/miniex/dotfiles.kitty) for matching font fallback / theme / keymaps.

![Preview](assets/preview.png)

## Highlights

- **Native LSP** — `vim.lsp.config` + `lsp/<server>.lua` discovery; mason-lspconfig handles install/enable
- **Native UI2** — floating cmdline + messages (`vim._core.ui2.enable()`); opt out via `vim.g.disable_ui2 = true`
- **Completion** — blink.cmp (Rust fuzzy), inlay hints suppressed during insert, tiny-inline-diagnostic
- **Treesitter** — `main` branch + textobjects, sticky context, ts-autotag, ts-context-commentstring
- **Pickers** — fff.nvim (Rust file finder) + snacks.picker (grep/buffers/recent) + fzf-lua (git/lsp/lines)
- **Editor** — neo-tree (floating), flash, trouble, which-key, todo-comments, dropbar, mini.surround, persistence, aerial, harpoon v2, grug-far, **quicker.nvim** (editable quickfix), **multicursor.nvim**, **undotree**, nvim-bqf, nvim-colorizer, git-conflict
- **snacks.nvim** — picker, profiler, terminal, dashboard, statuscolumn, notifier, indent, scroll, dim, image, bigfile
- **Markdown** — render-markdown.nvim inline rendering of headings / lists / tables / code
- **Tooling** — nvim-lint, mason-tool-installer, DAP (Rust/C-C++/Python/Go) with persistent breakpoints, neotest (Python/Go/Elixir/C++)
- **UI** — Catppuccin Mocha retoned to a 2-color damin palette (`#98ABCC` / `#E890B0`) mirroring [`fish-theme-damin`](https://github.com/miniex/fish-theme-damin) + [`dotfiles.kitty`](https://github.com/miniex/dotfiles.kitty) + [`dotfiles.tmux`](https://github.com/miniex/dotfiles.tmux). lualine: `✧ … ⋆` sparkle bookends, `✿` mode glyph (swaps to `✎` in visual / operator-pending, briefly `✦` on mode change). bufferline: pink → mid → blue 3-stop gradient, `♡` on harpoon-pinned. incline: `⌬` when window is zoomed (alone in tabpage). modicator: `✿` sign on the current line in mode color. LSP hover / signature / diagnostic floats use a flower-cornered border (`✿─✿│✿─✿│`). flash labels in damin pink. Plus edgy (sidebar layout), smear-cursor, fidget
- **Git** — gitsigns, fugitive, lazygit, diffview, **gitgraph.nvim** (in-buffer branch graph)
- **WSL2** clipboard bridge via `clip.exe`

## Language Support

| Language            | LSP                           | Linter           | Debugger |
| ------------------- | ----------------------------- | ---------------- | -------- |
| Shell (sh/bash)     | bashls                        | shellcheck       | -        |
| Zsh / Fish          | -                             | zsh -n / fish -n | -        |
| Assembly            | asm-lsp                       | -                | -        |
| C/C++               | clangd                        | -                | cpptools |
| Go                  | gopls                         | golangci-lint    | delve    |
| Rust                | rust-analyzer (rustaceanvim)  | -                | CodeLLDB |
| Zig                 | zls                           | -                | -        |
| OCaml               | ocamllsp                      | -                | -        |
| Elixir              | elixirls                      | -                | -        |
| Python              | basedpyright + ruff           | ruff (LSP)       | debugpy  |
| Lua                 | lua_ls                        | selene           | -        |
| CSS / HTML          | cssls / html+emmet            | -                | -        |
| Tailwind / JS-TS    | tailwindcss / vtsls           | eslint_d         | -        |
| GraphQL / SQL       | graphql / sqls                | -                | -        |
| JSON / YAML         | jsonls / yamlls               | -                | -        |
| Protobuf / TOML     | buf_ls / taplo                | -                | -        |
| RON                 | -                             | -                | -        |
| Typst               | tinymist                      | -                | -        |
| Markdown / MDX      | marksman / + mdx_analyzer     | markdownlint     | -        |
| CMake / Nix         | neocmake / nil_ls             | - / statix       | -        |
| Dockerfile / Helm   | dockerls / helm_ls            | hadolint         | -        |
| Terraform / HCL     | terraformls                   | tflint           | -        |
| Shaders (WGSL/GLSL) | wgsl-analyzer / glsl_analyzer | -                | -        |
| Just                | just-lsp                      | -                | -        |

> Formatting is opt-in via `tools/format.sh`, not on save.

## Setup

### Prerequisites

- **Neovim ≥ 0.12.0**
- `git`, `tar`, `curl`, `xxd`, C compiler, `make`, ripgrep
- A [Nerd Font](https://www.nerdfonts.com/) **plus** [`Symbols Nerd Font Mono`](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip) as fallback (many MDI glyphs are in the Supplementary PUA). In Kitty: `symbol_map U+E000-U+F8FF,U+F0000-U+10FFFD Symbols Nerd Font Mono`
- [`tree-sitter-cli`](https://github.com/tree-sitter/tree-sitter) **≥ 0.26.1** (`cargo install` or distro; **not npm**)
- Node.js + npm — for npm-based Mason packages
- Python 3 + pip, Go, Rust toolchains — required by Mason / debugpy / fff.nvim binary
- Zig / OCaml+opam / Erlang+Elixir — optional, only if the matching lang toggle is on
- [`just`](https://github.com/casey/just), [lazygit](https://github.com/jesseduffield/lazygit), [`fzf`](https://github.com/junegunn/fzf), [ImageMagick](https://imagemagick.org/) — optional (image previews require `magick`; animated GIFs show first frame only)

### Install

Mason auto-installs plugins, LSPs, linters, DAP adapters on first launch.

#### One-shot installer

Backs up existing config, optionally picks langs:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/miniex/dotfiles.nvim/main/install.sh)"
```

#### Manual

```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
git clone https://github.com/miniex/dotfiles.nvim.git ~/.config/nvim
sh ~/.config/nvim/set-lang.sh   # optional
nvim
```

#### Recovery

Broken after `git pull`? Nuke caches and restart:

```bash
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

## Essential Keymaps

Leader: `<Space>`. Full reference: [docs/KEYMAPS.md](docs/KEYMAPS.md).

| Key                         | Description                     |
| --------------------------- | ------------------------------- |
| `<leader>ff` / `<leader>fg` | Find files / live grep          |
| `<leader>e`                 | Toggle file tree (neo-tree)     |
| `s` / `S`                   | Flash jump / treesitter jump    |
| `<leader>w`                 | Smart buffer delete             |
| `<leader>t`                 | Toggle terminal                 |
| `<leader>S`                 | Search & replace (grug-far)     |
| `K` / `gd` / `gr`           | Hover / definition / references |
| `<leader>ca` / `<leader>rn` | Code action / rename            |
| `<leader>gg`                | LazyGit                         |
| `<leader>?`                 | which-key (buffer-local keys)   |

## Customization

- **Disable languages** — `sh ~/.config/nvim/set-lang.sh` (interactive) or hand-edit `lua/config/langs_local.lua` (gitignored). Overrides `lua/config/langs.lua` per-machine.
- **Add a language**:
  1. `lsp/<server>.lua` — server settings table (nvim-lspconfig provides `cmd`/`root_markers`/`filetypes` defaults)
  2. `lua/config/lang_servers.lua` — map `lang = { "server" }`. Empty list = no LSP, or owned by a per-lang plugin (e.g. rust → rustaceanvim)
  3. `lua/plugins/lang/<name>.lua` — DAP, treesitter parsers, lang-specific plugins. Register the module name in `lua/config/langs.lua`
  - Linters → `lua/plugins/lsp/lint.lua`. Non-LSP tools → `mason-tool-installer.nvim` ensure_installed.
- **Snippets** — drop Lua files in `~/.config/nvim/snippets/` (filetype-scoped, plus `all.lua`). VSCode JSON via friendly-snippets in parallel.
- **Theme** — `lua/plugins/ui/themes.lua`. Change `damin_blue` / `damin_pink` anchors at the top; the whole UI retones.
- **ui2** — toggle via `vim.g.disable_ui2 = true` in `globals.lua`.
- **Sidebar layout** — `lua/plugins/ui/edgy.lua` pins aerial → right, trouble/qf/dap → bottom.
- **Keymaps / autocmds** — `lua/config/keymaps.lua` and `autocmds.lua`.

## Companion repos

- [btop-theme-damin](https://github.com/miniex/btop-theme-damin) — btop theme
- [fish-theme-damin](https://github.com/miniex/fish-theme-damin) — fish prompt
- [dotfiles.tmux](https://github.com/miniex/dotfiles.tmux) — tmux config
- [dotfiles.kitty](https://github.com/miniex/dotfiles.kitty) — kitty terminal config

## Contributing

PRs welcome. Before opening: `./tools/format.sh` + `./tools/lint.sh` must pass clean. Commit prefix lowercase (`feat:`, `fix:`, …). Full details: [CONTRIBUTING.md](CONTRIBUTING.md).

## Troubleshooting

| Issue                    | Check                                                                            |
| ------------------------ | -------------------------------------------------------------------------------- |
| LSP not attaching        | `:Mason`, `:LspInfo`, `:LspLog`                                                  |
| LSP settings not applied | `lsp/<server>.lua` exists; server is in `lang_servers.lua` under an enabled lang |
| Lint not running         | linter on `$PATH`, see `lua/plugins/lsp/lint.lua`                                |
| Mason tools missing      | `:MasonToolsUpdate`, then `:Mason`                                               |
| `<leader>ff` not working | `:Lazy build fff.nvim` (Rust toolchain)                                          |
| ui2 cmdline glitches     | `vim.g.disable_ui2 = true` in `globals.lua`                                      |
| Profiling startup        | `PROF=1 nvim`, then `<leader>pp` / `<leader>pf`                                  |
| Treesitter errors        | `:checkhealth nvim-treesitter`; `tree-sitter --version` ≥ 0.26.1 (not npm)       |
| Theme not updating       | `rm -rf ~/.cache/nvim/catppuccin` and restart                                    |

> nvim-treesitter `master` is archived and incompatible with 0.12; pinned to `main`.

## License

[MIT](LICENSE) © 2024-2026 Han Damin.

**Exception:** `assets/dashboard_sticker.ansi` and `assets/preview.png` derive from a copyrighted character and are **not** MIT-licensed. Remove both before redistributing. See [`assets/LICENSE`](assets/LICENSE).
