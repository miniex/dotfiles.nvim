# Contributing

Every commit must pass `just fmt` + `just lint` clean.

## Tools

Required (`just fmt` / `just lint` fail without these):

- [`just`](https://github.com/casey/just) — task runner
- [`stylua`](https://github.com/JohnnyMorganz/StyLua) — Lua formatter
- [`lua-language-server`](https://github.com/LuaLS/lua-language-server) — Lua diagnostics
- [`selene`](https://github.com/Kampfkarren/selene) — Lua linter (reads `selene.toml` + `vim.toml`)
- [`shfmt`](https://github.com/mvdan/sh) — shell formatter
- [`shellcheck`](https://www.shellcheck.net/) — shell linter

Optional (used opportunistically; recipes skip them if absent):

- [`jq`](https://jqlang.github.io/jq/) — JSON pretty-print (`just fmt`, `--indent 4`)
- [`taplo`](https://taplo.tamasfe.dev/) — TOML formatter (`just fmt`)
- [`yamlfmt`](https://github.com/google/yamlfmt) — YAML formatter (`just fmt`)
- `fish`, `zsh` — `just lint` runs `fish -n` / `zsh -n` on tracked `*.fish` / `*.zsh` files

```bash
brew install just stylua lua-language-server shfmt shellcheck   # macOS
brew install jq taplo yamlfmt                                   # optional
cargo install stylua selene just                                # cargo
# Linux: distro package or release tarball
```

## Workflow

All tasks live in the `justfile`:

```bash
just fmt     # stylua + shfmt rewrite; jq/taplo/yamlfmt on tracked files when present
just lint    # stylua --check + lua-language-server + selene + shfmt diff + shellcheck
             # + fish -n / zsh -n on tracked *.fish / *.zsh files when present
just check   # diagnose host prereqs + format/lint tools (tree-sitter, fonts, stylua/selene/…); never fails
```

`just lint` exits non-zero on drift or diagnostic; keep it clean before pushing. `just check` is informational.

## PR rules

- One concern per PR.
- Update `README.md` / `docs/KEYMAPS.md` when behavior, keymaps, or prereqs change.
- Module layout:
    - `lua/config/` — global config
    - `lua/plugins/{coding,editor,lang,lsp,ui}/` — plugin specs
    - `after/lsp/<server>.lua` — per-server settings (0.11+ native discovery). Single source for `cmd` / `root_markers` / `filetypes` / `settings`; don't restate via `nvim-lspconfig.opts.servers.<name>`. For a server whose bundled config defines a `root_dir` (e.g. svelte), override it with a `root_dir` here — `root_markers` is ignored then.
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
