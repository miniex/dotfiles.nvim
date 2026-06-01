# Customization

## Languages

### Disable

```bash
sh ~/.config/nvim/set-lang.sh   # interactive
```

Or hand-edit `lua/config/langs_local.lua` (gitignored). Overrides `lua/config/langs.lua` per-machine.

Re-enabling a language installs its Mason tools automatically on the next launch (mason-tool-installer runs on start, ~3s deferred) — no manual `:MasonToolsInstall` needed.

### Add a new language

1. `lsp/<server>.lua` — single source for `cmd` / `root_markers` / `filetypes` / `settings`. Don't restate via `nvim-lspconfig.opts.servers.<name>`.
2. `lua/config/lang_servers.lua` — map `lang = { "server" }`. Empty list = no LSP (or owned by a per-lang plugin like `rust → rustaceanvim`). An enabled lang with **no** key here warns on startup (no silent missing LSP).
3. `lua/plugins/lang/<name>.lua` — DAP, `vim.filetype.add`, lang-specific plugins. Register the module name in `lua/config/langs.lua`.
4. Treesitter grammar → add it to the central `ensure_installed` list in `lua/plugins/editor/treesitter.lua` (lang files no longer extend it themselves).

Linters → `lua/plugins/lsp/lint.lua`. Non-LSP CLI tools → `mason-tool-installer.nvim` `ensure_installed`. CodeLLDB-based DAP (C/C++, Zig) → shared resolver `lua/config/codelldb.lua`.

## Snippets

Drop Lua files in `~/.config/nvim/snippets/`. Filetype-scoped by filename (e.g. `lua.lua`), plus `all.lua` for cross-filetype tokens (`uuid` / `iso` / `todo` / `fixme` / `note`). VSCode JSON snippets via friendly-snippets run in parallel. Many languages ship snippet sets too (`cmake` / `just` / `terraform` / `proto` / `graphql` / `typst` / `helm` / `wgsl` / `glsl` / `asm` / `ocaml` / `dune` / `json`).

## Theme

- `lua/config/palette.lua` — the two brand accents (`blue` / `pink`) and git accents (`git_add` / `git_delete`) live here; every UI plugin reads them, so changing one value retones the whole UI.
- `lua/plugins/ui/themes.lua` maps those accents onto highlight groups.
- Border characters live in `lua/config/globals.lua` (`vim.g.flower_border`).

## ui2

- Toggle with `vim.g.disable_ui2 = true` in `lua/config/globals.lua`.

## Sidebar layout

- `lua/plugins/ui/edgy.lua` pins aerial → right, trouble / qf / dap-repl → bottom.

## Scroll animation

- `lua/plugins/ui/snacks.lua` (`scroll` block) — `animate.duration.total` for one-shot length, `animate_repeat.duration.total` for held j/k (keep short or key-repeat lags). `easing` accepts `linear` / `outQuad` / `outCubic`.

## Picker / terminal exclusions

`lua/config/chrome_filetypes.lua` is the single source — `pickers` (snacks/fff/fzf overlays) and `panels` (neo-tree, trouble, dap, aerial, …). scrollbar / smear-cursor / cursor-bloom / incline all build their exclusions from it. Add a new float's filetype to `pickers` or `panels` once and every chrome plugin picks it up.

## Per-filetype options

- `after/ftplugin/<ft>.lua` — buffer-local options Neovim auto-sources on `FileType`. Used for `go` / `make` (tabs, overriding the global `expandtab`) and `gitcommit` / `markdown` (spell, wrap, 72-col). Add a file named after the filetype to set its own buffer options.
- `rust` / `python` set `colorcolumn` to the project formatter's width — `rustfmt.toml` `max_width` or `ruff` / `pyproject.toml` `line-length`, searched upward, else 100 / 88. Resolver: `lua/config/format-width.lua` (add a `{ names, pattern }` source to extend).

## Keymaps / autocmds

- Global keymaps in `lua/config/keymaps.lua`.
- Autocmds in `lua/config/autocmds.lua`.
- Per-LSP-buffer maps in `lua/plugins/lsp/init.lua` (LspAttach callback).

## Modal floats

- `lua/config/modal-floats.lua` — mutual-exclusion registry + shared float-config decorator hook. Extend `OWNER` (`ft = "owner"`) to register a new modal; same `owner` keeps siblings together. Use `add_decorator(name, { open, set_config })` to rewrite float configs (border, title, geometry) without patching the APIs yourself.
- `lua/config/modal-geom.lua` — shared geometry. Change `M.RATIO` to resize every modal float at once. Add a filetype to `ALIGNED_FT` to snap a new plugin into the same rectangle. The `VimResized` handler re-snaps every visible modal on terminal/tmux resize, so the rectangle holds mid-session too.

## DAP

- Adapters & language launch configs in `lua/plugins/lang/<lang>.lua` (e.g. zig, elixir, c-cpp).
- For a new language that configures `nvim-dap` directly, append a setup function to **`opts.setups`** (run once by the single `config` in `lua/plugins/lsp/dap.lua`):

    ```lua
    { "mfussenegger/nvim-dap", optional = true, opts = function(_, opts)
        opts.setups = opts.setups or {}
        table.insert(opts.setups, function(dap) dap.configurations.X = { ... } end)
    end }
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

`blink.cmp` sources filtered per filetype in `lua/plugins/coding/completion.lua` (`per_filetype` table). Add an entry when a filetype needs its own source mix. A lang plugin can add its own sources via an `optional = true` `blink.cmp` spec — set only `per_filetype` / `providers`, not `default` (e.g. `lua/plugins/lang/sql.lua` for SQL/dadbod).
