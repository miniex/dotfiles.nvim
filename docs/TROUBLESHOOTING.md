# Troubleshooting

| Issue                                             | Check                                                                                                                                           |
| ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| LSP not attaching                                 | `:Mason`, `:LspInfo`, `:LspLog`                                                                                                                 |
| LSP settings not applied                          | `lsp/<server>.lua` exists; server is in `lang_servers.lua` under an enabled lang; not restated via `nvim-lspconfig.opts.servers.<name>`         |
| Lint not running                                  | linter on `$PATH`, see `lua/plugins/lsp/lint.lua`. Fires on save / read (250ms debounce); save to re-run after edits.                           |
| Mason tools missing                               | `:MasonToolsUpdate`, then `:Mason`                                                                                                              |
| Python debug fails                                | `:MasonInstall debugpy` — `nvim-dap-python` warns and skips setup if missing                                                                    |
| `<leader>ff` not working                          | `:Lazy build fff.nvim` (Rust toolchain)                                                                                                         |
| ui2 cmdline glitches                              | `vim.g.disable_ui2 = true` in `globals.lua`                                                                                                     |
| Profiling startup                                 | `PROF=1 nvim` auto-captures the startup; `<leader>Pf` to pick frames                                                                            |
| Treesitter errors                                 | `:checkhealth nvim-treesitter`; `tree-sitter --version` ≥ 0.26.1 (not npm)                                                                      |
| Theme not updating                                | `rm -rf ~/.cache/nvim/catppuccin` and restart                                                                                                   |
| Missing prereq tools                              | `./tools/health.sh` — flags tree-sitter version, Nerd Font fallback, toolchains, clipboard bridge                                               |
| Lazy sync stuck / broken                          | `:Lazy sync` (force) or `:Lazy restore` (revert to `lazy-lock.json`); nuke caches as a last resort                                              |
| Snippets not appearing                            | `:Lazy reload friendly-snippets` and `:LuaSnipUnlinkCurrent` if mid-expansion; check filetype matches a file in `snippets/`                     |
| Neotest discovery fails                           | adapter for that language is missing or its CLI isn't on `$PATH` (`pytest` / `go` / `mix` / `gtest` / `cargo`)                                  |
| Dashboard preceded by flickering `[No Name]` tabs | Stale persistence session for the cwd. Delete it: `rm ~/.local/state/nvim/sessions/$(pwd \| tr / %).vim`                                        |
| `:q` swaps to an unexpected buffer after restore  | Old session file has stale `badd` lines; `:qa` once to overwrite, or `rm` it                                                                    |
| Typing lag in `<leader>t` / pickers (fzf / fff)   | New picker/terminal float? Add its filetype to `excluded_ft` (`scrollbar.lua` + `modicator.lua`) and `sticky_disabled_ft` (`smear-cursor.lua`). |

> nvim-treesitter `master` is archived and incompatible with 0.12; pinned to `main`.
