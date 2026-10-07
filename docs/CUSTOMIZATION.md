# Customization

## Languages

### Enable / disable

A core set is on by default (`langs.lua`); enable the rest — or turn core ones off — with:

```bash
just lang   # interactive (or: sh ~/.config/nvim/scripts/set-lang.sh)
```

Or hand-edit `lua/config/langs_local.lua` (gitignored): `name = true` / `name = false` overrides `lua/config/langs.lua` per-machine.

Enabling a language installs its Mason tools automatically on the next launch (mason-tool-installer runs on start, ~3s deferred) — no manual `:MasonToolsInstall` needed.

### Add a new language

1. `after/lsp/<server>.lua` — single source for `cmd` / `root_markers` / `filetypes` / `settings`. Don't restate via `nvim-lspconfig.opts.servers.<name>`. Optional: omit it to inherit nvim-lspconfig's bundled defaults. Caveat: `root_markers` only applies when the bundled config has no `root_dir`; for one that does (e.g. svelte), set a `root_dir` here instead.
2. `lua/config/lang_servers.lua` — map `lang = { "server" }`. Empty list = no LSP (or owned by a per-lang plugin like `rust → rustaceanvim`). An enabled lang with **no** key here warns on startup (no silent missing LSP).
3. `lua/plugins/lang/<name>.lua` — DAP, `vim.filetype.add`, lang-specific plugins. Register the module name in `lua/config/langs.lua`.
4. Treesitter grammar → `require("config.lang").treesitter({ "<parser>" })` in that lang's file, so it installs only when the lang is on. Always-needed parsers (vim, lua, markdown, git, …) stay in `lua/plugins/editor/treesitter.lua`.

Language-agnostic servers (e.g. `typos_lsp`) aren't mapped per-language — they're appended in `enabled_servers()` (`lua/plugins/lsp/init.lua`) so they run regardless of `langs.lua`.

Client-side file watching (`didChangeWatchedFiles`) is on for every server, which can stall a large project on open. Fix per server: a server-side watcher (rust-analyzer's `files.watcher = "server"`) or `dynamicRegistration = false` in its `after/lsp/<server>.lua`.

Linters → `lua/plugins/lsp/lint.lua`. Non-LSP CLI tools → `mason-tool-installer.nvim` `ensure_installed`. CodeLLDB-based DAP (C/C++, Zig, Nim, Rust) → shared resolver `lua/config/codelldb.lua`. Repeated lang-spec fragments (mason / treesitter / blink / lint / code-action keys) have one-line helpers in `lua/config/lang.lua`; DAP mason-binary guards in `lua/config/dap.lua`. JSON/YAML SchemaStore wiring → shared `lua/config/lsp_schemastore.lua`. Semantic tokens are disabled for vtsls / basedpyright / clangd centrally in `lua/plugins/lsp/init.lua` (`SEMANTIC_TOKENS_OFF`).

## Snippets

Drop Lua files in `~/.config/nvim/snippets/`. Filetype-scoped by filename (e.g. `lua.lua`), plus `all.lua` for cross-filetype tokens (`uuid` / `iso` / `todo` / `fixme` / `note`). VSCode JSON snippets via friendly-snippets run in parallel. Most languages ship a set too — see `snippets/`. Shared node constructors (`s` / `i` / `fmt` / `fmtd` / `today` / …) come from `require("config.snippets")`. Jump to the current filetype's snippet file with `<leader>fs`.

## Theme

- `lua/config/palette.lua` — the two brand accents (`blue` / `pink`) and git accents (`git_add` / `git_delete`) live here; every UI plugin reads them, so changing one value retones the whole UI.
- `lua/plugins/ui/themes.lua` maps those accents onto highlight groups.
- Border characters live in `lua/config/globals.lua` (`vim.g.flower_border`).

## ui2

- Toggle with `vim.g.disable_ui2 = true` in `lua/config/options.lua`.

## Statusline

- `lua/config/statusline.lua` — hand-rolled `%!` render function; segments, mode labels (`MODES`), and `Stl*` highlight groups all live there. Colors come from `config.palette`.

## Picker / terminal exclusions

Cursor chrome skips any non-file buffer (`buftype ~= ""`): pickers, panels, terminals and the dashboard need no list. smear-cursor also takes `filetypes_disabled` in `lua/plugins/ui/smear-cursor.lua`.

## Per-filetype options

- `after/ftplugin/<ft>.lua` — buffer-local options Neovim auto-sources on `FileType` (after the built-in / plugin ftplugins, so it wins). Used for `gitcommit` (50/72 guides) and `json` (2-space); stock ftplugins already cover go/make tabs and yaml indent. Add a file named after the filetype to set its own buffer options.

## Formatter width

`textwidth` (the `gq` / `gw` reflow width) is a per-filetype formatter default (`TEXTWIDTH` in `lua/config/autocmds.lua`: rust 100, python 88, lua 120, elixir 98, c/cpp/ocaml/sql/toml 80). A project's `.editorconfig` `max_line_length` overrides it via the stock editorconfig plugin.

## Keymaps / autocmds

- Global keymaps in `lua/config/keymaps.lua`.
- Autocmds in `lua/config/autocmds.lua`.
- Per-LSP-buffer maps in `lua/plugins/lsp/init.lua` (LspAttach callback).

## Big-file handling

Two size tiers, smallest first:

- **> 1 MiB** (or a >2000-char first line) — treesitter (`ts-attach` in `lua/config/autocmds.lua`), rainbow-delimiters (also >10000 lines), and LSP CodeLens / reference highlight are skipped (size check cached per buffer); colorizer detaches on a >2000-char first line.
- **> 2 MiB** — `snacks.bigfile` degrades features (LSP / treesitter / syntax / folds / matchparen) and colorizer skips it (`!bigfile`). Tune `size` in `lua/plugins/ui/snacks.lua`.

Separately, files **> 10 MiB** are skipped by the focus-time `:checktime` auto-reload (per buffer, size cached), so a changed huge file isn't reloaded on every focus (`lua/config/autocmds.lua`).

The statusline search match count is skipped in buffers **> 20000 lines** — `searchcount()` rescans the buffer per cursor move (~24 ms at 200k lines). Tune `SEARCHCOUNT_MAX_LINES` in `lua/config/statusline.lua`.

## Modal floats

- `lua/config/modal-floats.lua` — mutual-exclusion registry. Extend `OWNER` (`ft = "owner"`) to register a new modal; same `owner` keeps siblings together.
- `lua/config/modal-geom.lua` — shared geometry. Change `M.RATIO` to resize the snacks / fzf-lua / gitsigns modals at once.

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

## TODO tags

- todo-comments tags in `lua/plugins/editor/todo-comments.lua`.

## Per-project config

`vim.opt.exrc = true` loads a `.nvim.lua` (or `.exrc`) from the cwd, gated by `vim.secure` on first open. Use for per-project indent / `colorcolumn` / extra keymaps.

## Startup profiling

`PROF=1 nvim` auto-captures the full startup via `snacks.profiler` (see `lua/config/lazy.lua`). Pick frames with `<leader>Pf`.

## Completion sources

`blink.cmp` sources filtered per filetype in `lua/plugins/coding/completion.lua` (`per_filetype` table). Add an entry when a filetype needs its own source mix. A lang plugin adds its own sources via the `require("config.lang").blink(per_filetype, providers)` helper — extend the global defaults with `inherit_defaults = true` rather than restating `default` (e.g. `lua/plugins/lang/lua.lua`, `sql.lua`).
