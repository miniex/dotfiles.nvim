# Contributing

Thanks for sending changes. The bar is small but firm: every commit and PR must pass `tools/format.sh` and `tools/lint.sh` cleanly.

## Required tools

Install on your `$PATH` before working on this repo:

- [`stylua`](https://github.com/JohnnyMorganz/StyLua) — formatter
- [`lua-language-server`](https://github.com/LuaLS/lua-language-server) — diagnostics (matches what nvim shows)

Examples:

```bash
# macOS
brew install stylua lua-language-server

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
