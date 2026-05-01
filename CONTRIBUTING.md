# Contributing

Thanks for sending changes. The bar is small but firm: every commit and PR must pass `tools/format.sh` and `tools/lint.sh` cleanly.

## Required tools

Install on your `$PATH` before working on this repo:

- [`stylua`](https://github.com/JohnnyMorganz/StyLua) — Lua formatter
- [`lua-language-server`](https://github.com/LuaLS/lua-language-server) — Lua diagnostics (matches what nvim shows)
- [`shfmt`](https://github.com/mvdan/sh) — shell script formatter
- [`shellcheck`](https://www.shellcheck.net/) — shell script linter

Examples:

```bash
# macOS
brew install stylua lua-language-server shfmt shellcheck

# cargo
cargo install stylua

# Linux: prefer your distro package, otherwise grab a release tarball.
```

## Workflow

Before every commit:

```bash
./tools/format.sh   # rewrites Lua files via stylua
./tools/lint.sh     # stylua --check + lua-language-server --check
```

`lint.sh` exits non-zero on any formatting drift or LSP diagnostic. CI / reviewers expect a clean run.

## PR expectations

- Keep changes scoped — one concern per PR.
- Update `README.md` when behavior, keymaps, or prerequisites change.
- Match the existing module layout (`lua/config/`, `lua/plugins/{coding,editor,lang,lsp,ui}/`).
- Don't commit `lazy-lock.json` churn unless the PR is explicitly a plugin bump.
- Do **not** add, modify, or copy files under `assets/` — that directory is licensed separately (`assets/LICENSE`) and contributions there are not accepted.

## Commit messages

Follow the prefixes already in `git log`. Shape: `prefix(scope?): description`.

Common prefixes: `feat`, `fix`, `refactor`, `perf`, `docs`, `chore`, `tools`.

Rules:

- **Prefix is always lowercase** — `feat:` not `Feat:`.
- **First word after the prefix is always lowercase** — `fix: handle empty buffer`, not `fix: Handle empty buffer`.
- The rest of the description follows no strict case rule, but prefer lowercase. Reserve uppercase for proper nouns, acronyms, or genuine emphasis.

Examples:

```
feat: add inlay hint toggle
fix(treesitter): retry attach on BufEnter
refactor(lsp): migrate to vim.lsp.config
docs: clarify language wiring
```

Single-line, imperative mood. No trailing period.
