# Contributing

Every commit must pass `tools/format.sh` + `tools/lint.sh` clean.

## Tools

Install on `$PATH`:

- [`stylua`](https://github.com/JohnnyMorganz/StyLua) — Lua formatter
- [`lua-language-server`](https://github.com/LuaLS/lua-language-server) — Lua diagnostics
- [`shfmt`](https://github.com/mvdan/sh) — shell formatter
- [`shellcheck`](https://www.shellcheck.net/) — shell linter

```bash
brew install stylua lua-language-server shfmt shellcheck   # macOS
cargo install stylua                                       # cargo
# Linux: distro package or release tarball
```

## Workflow

```bash
./tools/format.sh   # stylua rewrite
./tools/lint.sh     # stylua --check + lua-language-server + shfmt diff + shellcheck
```

`lint.sh` exits non-zero on drift or diagnostic. CI expects clean.

## PR rules

- One concern per PR.
- Update `README.md` / `docs/KEYMAPS.md` when behavior, keymaps, or prereqs change.
- Module layout:
  - `lua/config/` — global config
  - `lua/plugins/{coding,editor,lang,lsp,ui}/` — plugin specs
  - `lsp/<server>.lua` at repo root — per-server settings (0.11+ native discovery)
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
