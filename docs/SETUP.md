# Setup

## Prerequisites

- **Neovim ≥ 0.12.0**
- `git`, `tar`, `curl`, `xxd`, C compiler, `make`, ripgrep
- A [Nerd Font](https://www.nerdfonts.com/) **plus** [`Symbols Nerd Font Mono`](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip) as fallback (many MDI glyphs sit in the Supplementary PUA). In Kitty: `symbol_map U+E000-U+F8FF,U+F0000-U+10FFFD Symbols Nerd Font Mono`
- [`tree-sitter-cli`](https://github.com/tree-sitter/tree-sitter) **≥ 0.26.1** (`cargo install` or distro; **not npm**)
- Node.js + npm — for npm-based Mason packages
- Python 3 + pip, Go, Rust toolchains — required by Mason / debugpy / fff.nvim binary
- Zig / OCaml+opam / Erlang+Elixir — optional, only if the matching lang toggle is on
- [`just`](https://github.com/casey/just), [lazygit](https://github.com/jesseduffield/lazygit), [`fzf`](https://github.com/junegunn/fzf), [ImageMagick](https://imagemagick.org/) — optional (image previews require `magick`; animated GIFs show first frame only)
- Database client CLIs (`psql` / `mysql` / `sqlite3`) — optional, only for `:DBUI` / dadbod against the matching engine

Run `./tools/health.sh` to verify everything in one shot.

## Install

Mason auto-installs plugins, LSPs, linters, and DAP adapters on first launch — and again on later launches for any newly enabled language (no manual step).

### One-shot installer

Backs up existing config, optionally picks langs:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/miniex/dotfiles.nvim/main/install.sh)"
```

### Manual

```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
git clone https://github.com/miniex/dotfiles.nvim.git ~/.config/nvim
sh ~/.config/nvim/set-lang.sh   # optional
nvim
```

## Recovery

Broken after `git pull`? Nuke caches and restart:

```bash
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```
