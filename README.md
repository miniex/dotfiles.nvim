# Neovim Configuration

Lean, fast, easy on the eyes. Native LSP via `lsp/<server>.lua` discovery, Rust-backed completion (blink.cmp), aggressive lazy-loading.

> **Targets Linux/macOS in [Kitty](https://sw.kovidgoyal.net/kitty/)** (image previews also work in WezTerm / Ghostty via the kitty graphics protocol). WSL2 supported via `clip.exe`. Other terminals work, minus inline image previews and the Material Design Icons fallback.
>
> Pairs with [`miniex/dotfiles.kitty`](https://github.com/miniex/dotfiles.kitty) for matching font fallback / theme / keymaps.

![Preview](assets/preview.png)

## Highlights

- **Native LSP & ui2** — `vim.lsp.config` + `lsp/<server>.lua` discovery; floating cmdline + messages
- **Completion** — blink.cmp (Rust fuzzy) + tiny-inline-diagnostic
- **Treesitter** — `main` branch, textobjects, sticky context, ts-autotag, ts-context-commentstring
- **Pickers** — fff.nvim + snacks.picker + fzf-lua, all sharing one 0.85 × 0.85 rectangle
- **Editor** — Neo-tree, flash, Trouble, harpoon v2, dial, multicursor, refactoring, quicker, grug-far, …
- **UI** — Catppuccin Mocha retoned to a 2-color damin palette (`#98ABCC` / `#E890B0`); flower-cornered borders on every floating window
- **Modal floats** — pickers / terminal / lazy / Mason / harpoon / lazygit / Neo-tree are mutually exclusive and land in the exact same 0.85 × 0.85 chrome-aware rectangle
- **Tooling** — nvim-lint, mason-tool-installer, DAP (6 langs), neotest (7 langs), vim-dadbod-ui (SQL client)
- **Git** — gitsigns, fugitive, lazygit, Diffview, gitgraph.nvim
- **Clipboard** — yank → wl-copy / xclip / pbcopy / clip.exe (whichever is on PATH first), else OSC52 over SSH

Full breakdown: [docs/FEATURES.md](docs/FEATURES.md).

## Quick start

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/miniex/dotfiles.nvim/main/install.sh)"
```

Prerequisites, manual install, and recovery: [docs/SETUP.md](docs/SETUP.md).

## Language Support

| Language            | LSP                                                  | Linter           | Debugger                                 |
| ------------------- | ---------------------------------------------------- | ---------------- | ---------------------------------------- |
| Shell (sh/bash)     | bashls                                               | shellcheck       | -                                        |
| Zsh / Fish          | - / fish-lsp                                         | zsh -n / fish -n | -                                        |
| Assembly            | asm-lsp                                              | -                | -                                        |
| C/C++               | clangd                                               | -                | codelldb                                 |
| Go                  | gopls                                                | golangci-lint    | delve                                    |
| Templ               | templ (+ html)                                       | -                | -                                        |
| Rust                | rust-analyzer (rustaceanvim)                         | -                | codelldb                                 |
| Zig                 | zls                                                  | -                | codelldb                                 |
| Nim                 | nim_langserver                                       | -                | -                                        |
| OCaml               | ocamllsp                                             | -                | -                                        |
| Elixir              | elixirls                                             | -                | elixir-ls debug adapter                  |
| Python              | basedpyright + ruff                                  | ruff (LSP)       | debugpy                                  |
| Lua                 | lua_ls                                               | selene           | -                                        |
| PHP                 | intelephense                                         | -                | php-debug-adapter (Xdebug)               |
| CSS / HTML          | cssls / html+emmet                                   | -                | -                                        |
| Tailwind / JS-TS    | tailwindcss / vtsls                                  | eslint_d         | js-debug-adapter (Node) + Chrome/Firefox |
| Svelte/Vue/Astro    | svelte / vue_ls (+ vtsls) / astro                    | -                | -                                        |
| GraphQL / SQL       | graphql / sqls                                       | - / sqlfluff     | -                                        |
| JSON / YAML         | jsonls / yamlls                                      | - / yamllint     | -                                        |
| Protobuf / TOML     | buf_ls / taplo                                       | -                | -                                        |
| RON                 | -                                                    | -                | -                                        |
| Typst               | tinymist                                             | -                | -                                        |
| Markdown / MDX      | marksman / mdx_analyzer                              | markdownlint     | -                                        |
| CMake / Nix         | neocmake / nil_ls                                    | - / statix       | -                                        |
| Dockerfile / Helm   | dockerls / docker_compose_language_service / helm_ls | hadolint         | -                                        |
| Terraform / HCL     | terraformls                                          | tflint           | -                                        |
| Shaders (WGSL/GLSL) | wgsl-analyzer / glsl_analyzer                        | -                | -                                        |
| Just                | just-lsp                                             | -                | -                                        |

> Formatting is manual via `<leader>cf` (native LSP), not on save.
>
> `typos_lsp` spell-checks all filetypes (low false-positive), independent of the table above.

## Essential Keymaps

Leader: `<Space>`. Full reference: [docs/KEYMAPS.md](docs/KEYMAPS.md).

| Key                         | Description                     |
| --------------------------- | ------------------------------- |
| `<leader>ff` / `<leader>fg` | Find files / live grep          |
| `<leader>e`                 | Toggle file tree (Neo-tree)     |
| `s` / `S`                   | flash jump / treesitter jump    |
| `<leader>w`                 | Smart buffer delete             |
| `<S-h>` / `<S-l>`           | Previous / next buffer          |
| `<leader>t`                 | Toggle terminal                 |
| `<leader>rr`                | Search & replace (grug-far)     |
| `K` / `gd` / `gr`           | Hover / definition / references |
| `<leader>ca` / `<leader>rn` | Code action / rename            |
| `<leader>gg`                | lazygit                         |
| `<leader>?`                 | which-key (all keymaps)         |

## Documentation

- [docs/SETUP.md](docs/SETUP.md) — prerequisites, install, recovery
- [docs/FEATURES.md](docs/FEATURES.md) — per-category feature breakdown
- [docs/KEYMAPS.md](docs/KEYMAPS.md) — every keymap
- [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) — where to edit what
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — why files live where they do
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) — common issues

## Companion repos

- [btop-theme-damin](https://github.com/miniex/btop-theme-damin) — btop theme
- [fish-theme-damin](https://github.com/miniex/fish-theme-damin) — fish prompt
- [dotfiles.tmux](https://github.com/miniex/dotfiles.tmux) — tmux config
- [dotfiles.kitty](https://github.com/miniex/dotfiles.kitty) — kitty terminal config

## Contributing

PRs welcome. Before opening: `./tools/format.sh` + `./tools/lint.sh` must pass clean. Run `./tools/health.sh` to verify host prereqs (tree-sitter, Nerd Fonts, toolchains). Commit prefix lowercase (`feat:`, `fix:`, …). Full details: [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © 2024-2026 Han Damin.

**Exception:** `assets/dashboard_sticker.ansi` and `assets/preview.png` derive from a copyrighted character and are **not** MIT-licensed. Remove both before redistributing. See [`assets/LICENSE`](assets/LICENSE).
