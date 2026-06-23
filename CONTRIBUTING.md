# Contributing

Every commit must pass `tools/format.sh` + `tools/lint.sh` clean.

## Tools

Required (`format.sh` / `lint.sh` fail without these):

- [`stylua`](https://github.com/JohnnyMorganz/StyLua) — Lua formatter
- [`lua-language-server`](https://github.com/LuaLS/lua-language-server) — Lua diagnostics
- [`selene`](https://github.com/Kampfkarren/selene) — Lua linter (reads `selene.toml` + `vim.toml`)
- [`shfmt`](https://github.com/mvdan/sh) — shell formatter
- [`shellcheck`](https://www.shellcheck.net/) — shell linter

Optional (used opportunistically; scripts skip with a warning if absent):

- [`jq`](https://jqlang.github.io/jq/) — JSON pretty-print (`format.sh`, `--indent 4`)
- [`taplo`](https://taplo.tamasfe.dev/) — TOML formatter (`format.sh`)
- [`yamlfmt`](https://github.com/google/yamlfmt) — YAML formatter (`format.sh`)
- [`just`](https://github.com/casey/just) — task runner (`just fmt`/`lint`/`health`); `format.sh`/`lint.sh` also format-check the justfile
- `fish`, `zsh` — `lint.sh` runs `fish -n` / `zsh -n` on tracked `*.fish` / `*.zsh` files

```bash
brew install stylua lua-language-server shfmt shellcheck   # macOS
brew install jq taplo yamlfmt just                         # optional
cargo install stylua selene just                           # cargo
# Linux: distro package or release tarball
```

## Workflow

Via the `justfile` wrapper: `just fmt` / `just lint` / `just health`. Or call the scripts directly:

```bash
./tools/format.sh   # stylua + shfmt rewrite; jq/taplo/yamlfmt on tracked files when present
./tools/lint.sh     # stylua --check + lua-language-server + selene + shfmt diff + shellcheck
                    # + fish -n / zsh -n on tracked *.fish / *.zsh files when present
./tools/health.sh   # diagnose host prereqs + format/lint tools (tree-sitter, fonts, stylua/selene/…); never fails
```

`lint.sh` exits non-zero on drift or diagnostic; keep it clean before pushing. `health.sh` is informational.

## PR rules

- One concern per PR.
- Update `README.md` / `docs/KEYMAPS.md` when behavior, keymaps, or prereqs change.
- Module layout:
    - `lua/config/` — global config
    - `lua/plugins/{coding,editor,lang,lsp,ui}/` — plugin specs
    - `lsp/<server>.lua` at repo root — per-server settings (0.11+ native discovery). Single source for `cmd` / `root_markers` / `filetypes` / `settings`; don't restate via `nvim-lspconfig.opts.servers.<name>`. For a server whose bundled config defines a `root_dir` (e.g. svelte), override it with a `root_dir` here — `root_markers` is ignored then.
    - `after/ftplugin/<ft>.lua` at repo root — per-filetype buffer options (auto-sourced on `FileType`).
    - `lua/config/lang_servers.lua` — lang ↔ server wiring
    - `lua/config/modal-floats.lua` — registry of mutually-exclusive modal floating UIs (extend `OWNER` to add a new one)
- Don't commit `lazy-lock.json` churn unless it's a plugin bump.
- **Don't** touch `assets/` — separate license, contributions not accepted.

## Commits

Shape: `prefix(scope?): description`. Prefixes: `feat`, `fix`, `refactor`, `perf`, `docs`, `chore`, `tools`.

- Prefix lowercase. First word after prefix lowercase. Imperative mood. No trailing period.

```
feat: add inlay hint toggle
fix(treesitter): retry attach on BufEnter
refactor(lsp): migrate to vim.lsp.config
docs: clarify language wiring
```
