# Architecture

Why files live where they do.

## Top-level layout

```
~/.config/nvim/
├── init.lua              entry point — required at root by Neovim
├── lsp/                  per-server settings (vim.lsp.config, 0.11+)
├── after/ftplugin/       per-filetype buffer options (auto-sourced on FileType)
├── snippets/             luasnip filetype-scoped + all.lua
├── lua/                  every require()-able module
│   ├── config/             core: options, autocmds, keymaps, lazy bootstrap
│   └── plugins/            plugin specs (lazy.nvim picks them up)
├── docs/                 markdown guides (this file)
├── tools/                shell helpers: format / lint / health
├── justfile              task runner (just fmt / lint / health)
├── scripts/              term-bin shims (term-bin/nvim → outer nvim)
├── assets/               dashboard sticker, preview image
├── CONTRIBUTING.md
└── README.md
```

The asymmetry between `lsp/` / `snippets/` (at root) and `lua/config|plugins/` (under `lua/`) is **dictated by Neovim**, not a stylistic choice — see below.

## Why each path is where it is

| Path                      | Forced by                                                                                       |
| ------------------------- | ----------------------------------------------------------------------------------------------- |
| `init.lua`                | Neovim looks here on startup. Cannot move.                                                      |
| `lsp/<server>.lua`        | Neovim 0.11+ native LSP discovery scans `<rtp>/lsp/` only. Cannot move.                         |
| `after/ftplugin/<ft>.lua` | Neovim auto-sources `<rtp>/after/ftplugin/<ft>.lua` on `FileType`. Cannot move.                 |
| `lua/<mod>/*.lua`         | `require("mod.x")` resolves to `<rtp>/lua/mod/x.lua`. Cannot move out of `lua/`.                |
| `snippets/<ft>.lua`       | Free choice. Path is set in `lua/plugins/coding/completion.lua` (`luasnip.loaders.from_lua`).   |
| `tools/`                  | Free. Shell scripts, not loaded by Neovim.                                                      |
| `scripts/term-bin/`       | Free. Used as `$EDITOR` inside the snacks terminal so `git commit` opens a split in outer nvim. |

## Boot sequence

`init.lua` requires in this order:

1. `config.globals` — `vim.g.*` shared across modules (`flower_border`, launch modes)
2. `config.options` — `vim.opt` settings (must precede plugins reading them, e.g. `cmdheight`, `laststatus`)
3. `config.autocmds` — global autocmds (clipboard sync, mkdir-on-save, ts-attach, …)
4. `config.modal-floats` — mutual-exclusion registry + shared `nvim_open_win` / `nvim_win_set_config` decorator hook
5. `config.keymaps` — global keymaps (not buffer-local)
6. `config.cursor-bloom` — mode-colored `✿` sign on the current line
7. `config.lazy` — bootstrap lazy.nvim and load `plugins.*` specs

Plugin specs are discovered by `lazy.setup({ spec = { { import = "plugins.coding" }, ... } })` in `lua/config/lazy.lua`. Per-language modules (`lua/plugins/lang/<lang>.lua`) are loaded only when the matching key in `lua/config/langs.lua` is `true`.

## Single sources of truth

| Concern                 | Lives in                                                             | Why                                                                                                                                                                                                                                                                                  |
| ----------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| LSP per-server settings | `lsp/<server>.lua`                                                   | Neovim's native discovery; don't restate in `nvim-lspconfig.opts.servers.<name>`.                                                                                                                                                                                                    |
| JSON/YAML schemas       | `lua/config/lsp_schemastore.lua`                                     | Shared SchemaStore wiring for jsonls/yamlls `before_init`; cached once, json append vs yaml merge in one place.                                                                                                                                                                      |
| Lang → server mapping   | `lua/config/lang_servers.lua`                                        | One place to ask "what servers does this language enable?"                                                                                                                                                                                                                           |
| Enabled languages       | `lua/config/langs.lua` (+ `langs_local.lua`)                         | `langs_local.lua` is gitignored and wins per-machine.                                                                                                                                                                                                                                |
| Diagnostic UI           | `lua/plugins/lsp/init.lua` `vim.diagnostic.config`                   | tiny-inline-diagnostic owns `virtual_text`; everything else (signs, float) lives here.                                                                                                                                                                                               |
| Modal float mutual-ex   | `lua/config/modal-floats.lua` `OWNER` table                          | Same `owner` keeps sibling windows of one plugin together; opening another owner closes prior.                                                                                                                                                                                       |
| Float config decorators | `lua/config/modal-floats.lua` `add_decorator()`                      | Single global `nvim_open_win` / `nvim_win_set_config` patch — plugins register name-keyed transforms.                                                                                                                                                                                |
| Modal float geometry    | `lua/config/modal-geom.lua`                                          | Shared 0.85 × 0.85 chrome-aware rectangle; tracks `VimResized`. Change `M.RATIO` to resize every modal at once.                                                                                                                                                                      |
| Border characters       | `lua/config/globals.lua` `vim.g.flower_border`                       | Every plugin reads this; theme/border consistency in one place.                                                                                                                                                                                                                      |
| Launch modes            | `lua/config/globals.lua` `single_file` / `file_launch` / `multi_dir` | `nvim` (full IDE); `nvim <dir>` chdir's in → dashboard (bare launch if inaccessible); `nvim <file>` (single, no session); multi-file (tabs, no session); `dir1 dir2` (per-dir tcd + dashboard, `:next`/`:prev` switch, manual session). Read by bufferline / persistence / autocmds. |
| Palette & brand accents | `lua/config/palette.lua`                                             | Cached `mocha()` parse + the `blue` / `pink` / git accents every UI plugin reads.                                                                                                                                                                                                    |
| UI chrome filetypes     | `lua/config/chrome_filetypes.lua`                                    | `pickers` / `panels` lists; scrollbar / smear / cursor-bloom / incline build exclusions from one source.                                                                                                                                                                             |
| Treesitter grammars     | `lua/plugins/editor/treesitter.lua` `ensure_installed`               | Central grammar list; lang files don't extend it.                                                                                                                                                                                                                                    |
| CodeLLDB DAP adapter    | `lua/config/codelldb.lua`                                            | Resolves the Mason codelldb binary once; shared by C/C++, Zig, Nim, and Rust.                                                                                                                                                                                                        |
| Formatter width         | `lua/config/format-width.lua`                                        | Per-filetype `textwidth` from the project formatter config (`rustfmt.toml`, `stylua`, `.clang-format`, …), searched upward; no visual ruler.                                                                                                                                         |
| Pager (`less`) view     | `lua/config/pager.lua`                                               | `less` in its own tab (read-only, streamed); shared by `<leader>L` and the >8 MiB big-file open gate.                                                                                                                                                                                |

## Plugin spec categories (`lua/plugins/`)

| Subdir    | Belongs here                                                                                                                    |
| --------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `coding/` | Completion (blink.cmp, LuaSnip, friendly-snippets).                                                                             |
| `editor/` | Editing UX: Neo-tree, flash, surround, harpoon, multicursor, git, …                                                             |
| `lang/`   | Per-language adapters (DAP configs, `vim.filetype.add`, lang-only plugins). Grammars live centrally in `editor/treesitter.lua`. |
| `lsp/`    | LSP infra (mason, nvim-lspconfig, lint, dap, neotest, diagnostic-ui).                                                           |
| `ui/`     | Theme, lualine, bufferline, snacks (picker/terminal/dashboard), edgy, …                                                         |

If a plugin touches multiple categories (e.g. snacks does picker + terminal + dashboard), pick the dominant one and add a comment if non-obvious.

## Where to look next

- [SETUP.md](SETUP.md) — install, prereqs, recovery
- [FEATURES.md](FEATURES.md) — what each feature does
- [KEYMAPS.md](KEYMAPS.md) — every keymap
- [CUSTOMIZATION.md](CUSTOMIZATION.md) — extension points for adding a language, theme tweak, etc.
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — common issues
