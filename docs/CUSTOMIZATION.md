# Customization

## Languages

### Enable / disable

A core set is on by default (`langs.lua`); enable the rest — or turn core ones off — with:

```bash
sh ~/.config/nvim/set-lang.sh   # interactive
```

Or hand-edit `lua/config/langs_local.lua` (gitignored): `name = true` / `name = false` overrides `lua/config/langs.lua` per-machine.

Enabling a language installs its Mason tools automatically on the next launch (mason-tool-installer runs on start, ~3s deferred) — no manual `:MasonToolsInstall` needed.

### Add a new language

1. `lsp/<server>.lua` — single source for `cmd` / `root_markers` / `filetypes` / `settings`. Don't restate via `nvim-lspconfig.opts.servers.<name>`. Optional: omit it to inherit nvim-lspconfig's bundled defaults.
2. `lua/config/lang_servers.lua` — map `lang = { "server" }`. Empty list = no LSP (or owned by a per-lang plugin like `rust → rustaceanvim`). An enabled lang with **no** key here warns on startup (no silent missing LSP).
3. `lua/plugins/lang/<name>.lua` — DAP, `vim.filetype.add`, lang-specific plugins. Register the module name in `lua/config/langs.lua`.
4. Treesitter grammar → add it to the central `ensure_installed` list in `lua/plugins/editor/treesitter.lua` (lang files no longer extend it themselves).

Language-agnostic servers (e.g. `typos_lsp`) aren't mapped per-language — they're appended in `enabled_servers()` (`lua/plugins/lsp/init.lua`) so they run regardless of `langs.lua`.

Client-side file watching (`didChangeWatchedFiles`) is on for every server, which can stall a large project on open. Fix per server: a server-side watcher (rust-analyzer's `files.watcher = "server"`) or `dynamicRegistration = false` in its `lsp/<server>.lua`.

Linters → `lua/plugins/lsp/lint.lua`. Non-LSP CLI tools → `mason-tool-installer.nvim` `ensure_installed`. CodeLLDB-based DAP (C/C++, Zig) → shared resolver `lua/config/codelldb.lua`. Repeated lang-spec fragments (mason / treesitter / blink / lint) have one-line helpers in `lua/config/lang.lua`; DAP mason-binary guards in `lua/config/dap.lua`. JSON/YAML SchemaStore wiring → shared `lua/config/lsp_schemastore.lua`. Semantic-tokens-disable `on_attach` (vtsls / basedpyright) → shared `lua/config/lsp_util.lua`.

## Snippets

Drop Lua files in `~/.config/nvim/snippets/`. Filetype-scoped by filename (e.g. `lua.lua`), plus `all.lua` for cross-filetype tokens (`uuid` / `iso` / `todo` / `fixme` / `note`). VSCode JSON snippets via friendly-snippets run in parallel. Many languages ship snippet sets too (`cmake` / `just` / `terraform` / `proto` / `graphql` / `typst` / `helm` / `wgsl` / `glsl` / `asm` / `ocaml` / `dune` / `json` / `vue` / `svelte` / `fish`). Shared node constructors (`s` / `i` / `fmt` / `fmtd` / `today` / …) come from `require("config.snippets")`.

## Theme

- `lua/config/palette.lua` — the two brand accents (`blue` / `pink`) and git accents (`git_add` / `git_delete`) live here; every UI plugin reads them, so changing one value retones the whole UI.
- `lua/plugins/ui/themes.lua` maps those accents onto highlight groups.
- Border characters live in `lua/config/globals.lua` (`vim.g.flower_border`).

## ui2

- Toggle with `vim.g.disable_ui2 = true` in `lua/config/globals.lua`.

## Sidebar layout

- `lua/plugins/ui/edgy.lua` pins aerial + neotest-summary → right, trouble / qf / dap-repl + neotest-output → bottom.

## Scroll animation

- `lua/plugins/ui/snacks.lua` (`scroll` block) — `animate.duration.total` for one-shot length, `animate_repeat.duration.total` for held j/k (keep short or key-repeat lags). `easing` accepts `linear` / `outQuad` / `outCubic`.

## Picker / terminal exclusions

`lua/config/chrome_filetypes.lua` is the single source — `pickers` (snacks/fff/fzf overlays) and `panels` (neo-tree, trouble, dap, aerial, …). scrollbar / smear-cursor / cursor-bloom / incline all build their exclusions from it. Add a new float's filetype to `pickers` or `panels` once and every chrome plugin picks it up.

## Per-filetype options

- `after/ftplugin/<ft>.lua` — buffer-local options Neovim auto-sources on `FileType` (after the built-in / plugin ftplugins, so it wins). Used for `go` / `make` (tabs, overriding the global `expandtab`) and `gitcommit` / `markdown` (wrap, 72-col). Add a file named after the filetype to set its own buffer options.

## Formatter width

`textwidth` (drives `gq` / `gw`) follows each project's formatter width — no visual ruler. A `FileType` autocmd in `lua/config/format-width.lua` reads a per-filetype `M.specs` registry, searches upward for the nearest config below, and uses its width (else the formatter default). Width `0` (e.g. clang-format `ColumnLimit: 0`) means no limit.

| Filetype    | Config (searched upward)                      | Key               | Default |
| ----------- | --------------------------------------------- | ----------------- | ------- |
| `rust`      | `rustfmt.toml` / `.rustfmt.toml`              | `max_width`       | 100     |
| `python`    | `ruff.toml` / `.ruff.toml` / `pyproject.toml` | `line-length`     | 88      |
| `lua`       | `stylua.toml` / `.stylua.toml`                | `column_width`    | 120     |
| `elixir`    | `.formatter.exs`                              | `line_length`     | 98      |
| `ocaml`     | `.ocamlformat`                                | `margin`          | 80      |
| `c` / `cpp` | `.clang-format`                               | `ColumnLimit`     | 80      |
| `sql`       | `.sqlfluff` / `pyproject.toml`                | `max_line_length` | 80      |
| `toml`      | `taplo.toml` / `.taplo.toml`                  | `column_width`    | 80      |

Add a language: add an entry to the `M.specs` table in `lua/config/format-width.lua` — one or more `{ names, pattern }` sources (each `pattern` captures the width as a single `(%d+)` group) plus a `default`. A string value aliases another filetype's spec (e.g. `cpp = "c"`):

```lua
<ft> = {
    sources = { { names = { "<config>" }, pattern = "^%s*<key>%s*[:=]%s*(%d+)" } },
    default = <default>,
},
```

## Keymaps / autocmds

- Global keymaps in `lua/config/keymaps.lua`.
- Autocmds in `lua/config/autocmds.lua`.
- Per-LSP-buffer maps in `lua/plugins/lsp/init.lua` (LspAttach callback).

## Big-file handling

Three size tiers, smallest first:

- **> 1 MiB** (or a >2000-char first line) — treesitter (`ts-attach` in `lua/config/autocmds.lua`) and rainbow-delimiters (also >10000 lines) are skipped.
- **> 2 MiB** — `snacks.bigfile` degrades features (LSP / treesitter / syntax / folds / matchparen) and colorizer skips it (`!bigfile`). Tune `size` in `lua/plugins/ui/snacks.lua`.
- **> 8 MiB** — opening prompts _view in `less`_ (default) / _edit anyway_ / _cancel_; binary files (NUL byte in the first KB) drop the pager option. Tune `BIG_FILE_LIMIT` in `lua/config/autocmds.lua`. Declining also drops it from the arglist, so the restored session won't reopen a `nvim hugefile`.

The "view" action and `<leader>L` open `less` in its own tab via `lua/config/pager.lua` (read-only, streamed — the only true no-read path). Needs `less` on `$PATH`.

## Modal floats

- `lua/config/modal-floats.lua` — mutual-exclusion registry + shared float-config decorator hook. Extend `OWNER` (`ft = "owner"`) to register a new modal; same `owner` keeps siblings together. Use `add_decorator(name, { open, set_config })` to rewrite float configs (border, title, geometry) without patching the APIs yourself.
- `lua/config/modal-geom.lua` — shared geometry. Change `M.RATIO` to resize every modal float at once. Add a filetype to `ALIGNED_FT` to snap a new plugin into the same rectangle. The `VimResized` handler re-snaps every visible modal on terminal/tmux resize, so the rectangle holds mid-session too. `M.scratch(lines, opts)` builds a centered flower scratch float (used by `:Messages`).

## DAP

- Adapters & language launch configs in `lua/plugins/lang/<lang>.lua` (e.g. zig, elixir, c-cpp).
- For a new language that configures `nvim-dap` directly, return `require("config.dap").spec(setup_fn)` — the shared `optional` fragment whose `setup_fn(dap)` registers adapters/configs (run once by the single `config` in `lua/plugins/lsp/dap.lua`):

    ```lua
    require("config.dap").spec(function(dap)
        dap.adapters.X = { ... }
        dap.configurations.X = { ... }
    end)
    ```

    Do **not** add a second `config` to `nvim-dap` from a lang file — lazy runs only one `config` per plugin, so they would collide nondeterministically. (Languages with their own plugin — `nvim-dap-go`, `nvim-dap-python` — keep `config` there.)

- Generic keymaps in `lua/plugins/lsp/dap.lua`.

## Neotest

- Adapters in `lua/plugins/lsp/neotest.lua`. Add an adapter and it joins the shared `<leader>n*` keymap.

## Snippets, dial, friendly tokens

- dial groups defined in `lua/plugins/editor/dial.lua` (extend for project-specific toggles like `staging↔prod`).
- todo-comments tags in `lua/plugins/editor/todo-comments.lua`.

## Per-project config

`vim.opt.exrc = true` loads a `.nvim.lua` (or `.exrc`) from the cwd, gated by `vim.secure` on first open. Use for per-project indent / `colorcolumn` / extra keymaps.

## Startup profiling

`PROF=1 nvim` auto-captures the full startup via `snacks.profiler` (see `lua/config/lazy.lua`). Pick frames with `<leader>Pf`.

## Completion sources

`blink.cmp` sources filtered per filetype in `lua/plugins/coding/completion.lua` (`per_filetype` table). Add an entry when a filetype needs its own source mix. A lang plugin adds its own sources via the `require("config.lang").blink(per_filetype, providers)` helper — extend the global defaults with `inherit_defaults = true` rather than restating `default` (e.g. `lua/plugins/lang/lua.lua`, `sql.lua`).
