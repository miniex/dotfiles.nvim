# Customization

## Languages

### Disable

```bash
sh ~/.config/nvim/set-lang.sh   # interactive
```

Or hand-edit `lua/config/langs_local.lua` (gitignored). Overrides `lua/config/langs.lua` per-machine.

### Add a new language

1. `lsp/<server>.lua` — single source for `cmd` / `root_markers` / `filetypes` / `settings`. Don't restate via `nvim-lspconfig.opts.servers.<name>`.
2. `lua/config/lang_servers.lua` — map `lang = { "server" }`. Empty list = no LSP (or owned by a per-lang plugin like `rust → rustaceanvim`).
3. `lua/plugins/lang/<name>.lua` — DAP, treesitter parsers, lang-specific plugins. Register the module name in `lua/config/langs.lua`.

Linters → `lua/plugins/lsp/lint.lua`. Non-LSP CLI tools → `mason-tool-installer.nvim` `ensure_installed`.

## Snippets

Drop Lua files in `~/.config/nvim/snippets/`. Filetype-scoped by filename (e.g. `lua.lua`), plus `all.lua` for cross-filetype tokens (`uuid` / `iso` / `todo` / `fixme` / `note`). VSCode JSON snippets via friendly-snippets run in parallel.

## Theme

- `lua/plugins/ui/themes.lua`. Change `damin_blue` / `damin_pink` anchors at the top; the whole UI retones.
- Border characters live in `lua/config/globals.lua` (`vim.g.flower_border`).

## ui2

- Toggle with `vim.g.disable_ui2 = true` in `lua/config/globals.lua`.

## Sidebar layout

- `lua/plugins/ui/edgy.lua` pins aerial → right, trouble / qf / dap-repl → bottom.

## Scroll animation

- `lua/plugins/ui/snacks.lua` (`scroll` block) — `animate.duration.total` for one-shot length, `animate_repeat.duration.total` for held j/k (keep short or key-repeat lags). `easing` accepts `linear` / `outQuad` / `outCubic`.

## Keymaps / autocmds

- Global keymaps in `lua/config/keymaps.lua`.
- Autocmds in `lua/config/autocmds.lua`.
- Per-LSP-buffer maps in `lua/plugins/lsp/init.lua` (LspAttach callback).

## Modal floats

- `lua/config/modal-floats.lua` — mutual-exclusion registry + shared float-config decorator hook. Extend `OWNER` (`ft = "owner"`) to register a new modal; same `owner` keeps siblings together. Use `add_decorator(name, { open, set_config })` to rewrite float configs (border, title, geometry) without patching the APIs yourself.
- `lua/config/modal-geom.lua` — shared geometry. Change `M.RATIO` to resize every modal float at once. Add a filetype to `ALIGNED_FT` to snap a new plugin into the same rectangle. The `VimResized` handler re-snaps every visible modal on terminal/tmux resize, so the rectangle holds mid-session too.

## DAP

- Adapters & language launch configs in `lua/plugins/lang/<lang>.lua` (e.g. zig, elixir, python).
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

`blink.cmp` sources filtered per filetype in `lua/plugins/coding/completion.lua` (`per_filetype` table). Add an entry when a filetype needs its own source mix.
