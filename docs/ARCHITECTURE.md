# Architecture

Why files live where they do.

## Top-level layout

```
~/.config/nvim/
├── init.lua              entry point — required at root by Neovim
├── after/                lsp/ per-server settings (vim.lsp.config), ftplugin/ per-filetype options
├── snippets/             luasnip filetype-scoped + all.lua
├── lua/                  every require()-able module
│   ├── config/             core: options, autocmds, keymaps, lazy bootstrap
│   └── plugins/            plugin specs (lazy.nvim picks them up)
├── docs/                 markdown guides (this file)
├── justfile              tasks: just fmt / lint / check
├── install.sh            one-shot installer (backup / update in place)
├── scripts/              set-lang.sh (lang toggles → gitignored langs_local.lua), _colors.sh
├── assets/               dashboard sticker, preview image
├── CONTRIBUTING.md
└── README.md
```

The asymmetry between `after/` / `snippets/` (at root) and `lua/config|plugins/` (under `lua/`) is **dictated by Neovim**, not a stylistic choice — see below.

## Why each path is where it is

| Path                      | Forced by                                                                                       |
| ------------------------- | ----------------------------------------------------------------------------------------------- |
| `init.lua`                | Neovim looks here on startup. Cannot move.                                                      |
| `after/lsp/<server>.lua`  | Native LSP discovery scans `<rtp>/lsp/`; `after/` merges over nvim-lspconfig's.                 |
| `after/ftplugin/<ft>.lua` | Neovim auto-sources `<rtp>/after/ftplugin/<ft>.lua` on `FileType`. Cannot move.                 |
| `lua/<mod>/*.lua`         | `require("mod.x")` resolves to `<rtp>/lua/mod/x.lua`. Cannot move out of `lua/`.                |
| `snippets/<ft>.lua`       | Free choice. Path is set in `lua/plugins/coding/completion.lua` (`luasnip.loaders.from_lua`).   |

## Boot sequence

`init.lua` requires in this order:

1. `config.globals` — `vim.g.*` shared across modules (`flower_border`, launch modes)
2. `config.options` — `vim.opt` settings (must precede plugins reading them, e.g. `cmdheight`, `laststatus`)
3. `config.autocmds` — global autocmds (clipboard sync, mkdir-on-save, ts-attach, …)
4. `config.modal-floats` — mutual-exclusion registry for modal floats
5. `config.keymaps` — global keymaps (not buffer-local)
6. `config.cursor-bloom` — mode-colored `✿` sign on the current line
7. `config.lazy` — bootstrap lazy.nvim and load `plugins.*` specs
8. `config.statusline` — hand-rolled global statusline

Plugin specs are discovered by `lazy.setup({ spec = { { import = "plugins.coding" }, ... } })` in `lua/config/lazy.lua`. Per-language modules (`lua/plugins/lang/<lang>.lua`) are loaded only when the matching key in `lua/config/langs.lua` is `true`.

## Single sources of truth

| Concern                 | Lives in                                                             | Why                                                                                                                                                                                                                                                                        |
| ----------------------- | -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| LSP per-server settings | `after/lsp/<server>.lua`                                             | Neovim's native discovery; don't restate in `nvim-lspconfig.opts.servers.<name>`.                                                                                                                                                                                          |
| JSON/YAML schemas       | `lua/config/lsp_schemastore.lua`                                     | Shared SchemaStore wiring for jsonls/yamlls `before_init`; cached once, json append vs yaml merge in one place.                                                                                                                                                            |
| Lang → server mapping   | `lua/config/lang_servers.lua`                                        | One place to ask "what servers does this language enable?"                                                                                                                                                                                                                 |
| Enabled languages       | `lua/config/langs.lua` (+ `langs_local.lua`)                         | `langs_local.lua` is gitignored and wins per-machine.                                                                                                                                                                                                                      |
| Diagnostic UI           | `lua/plugins/lsp/init.lua` `vim.diagnostic.config`                   | tiny-inline-diagnostic owns `virtual_text`; everything else (signs, float) lives here.                                                                                                                                                                                     |
| Modal float mutual-ex   | `lua/config/modal-floats.lua` `OWNER` table                          | Same `owner` keeps sibling windows of one plugin together; opening another owner closes prior.                                                                                                                                                                             |
| Modal float geometry    | `lua/config/modal-geom.lua`                                          | Shared 0.85 × 0.85 chrome-aware rectangle. Change `M.RATIO` to resize the snacks / fzf-lua / gitsigns modals.                                                                                                                                                              |
| Border characters       | `lua/config/globals.lua` `vim.g.flower_border`                       | Every plugin reads this; theme/border consistency in one place.                                                                                                                                                                                                            |
| Launch modes            | `lua/config/globals.lua` `file_launch` / `dir_launch`              | `nvim` (full IDE); `nvim <dir>` chdir's in → dashboard (bare launch if inaccessible); anything else (files, several dirs, stdin): buffers, no session. Read by persistence / autocmds / snacks.                                                                              |
| Palette & brand accents | `lua/config/palette.lua`                                             | Cached `mocha()` parse + the `blue` / `pink` / `dim` / git accents the statusline and UI plugins read.                                                                                                                                                                     |
| Treesitter grammars     | `config.lang.treesitter()` in lang files                             | Core parsers in `lua/plugins/editor/treesitter.lua`; each enabled lang adds its own.                                                                                                                                                                                       |
| CodeLLDB DAP adapter    | `lua/config/codelldb.lua`                                            | Resolves the Mason codelldb binary once; shared by C/C++, Zig, Nim, and Rust.                                                                                                                                                                                              |
| Formatter width         | `lua/config/autocmds.lua` `TEXTWIDTH`                                | Per-filetype `textwidth` defaults; `.editorconfig` `max_line_length` overrides (stock plugin).                                                                                                                                                                             |

## Plugin spec categories (`lua/plugins/`)

| Subdir    | Belongs here                                                                                                                    |
| --------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `coding/` | Completion (blink.cmp, LuaSnip, friendly-snippets).                                                                             |
| `editor/` | Editing UX: oil, flash, surround, git, …                                                                                        |
| `lang/`   | Per-language adapters (DAP configs, `vim.filetype.add`, lang-only plugins). Grammars live centrally in `editor/treesitter.lua`. |
| `lsp/`    | LSP infra (mason, nvim-lspconfig, lint, dap, neotest, diagnostic-ui).                                                           |
| `ui/`     | Theme, snacks (picker/terminal/dashboard), smear-cursor, devicons.                                                              |

If a plugin touches multiple categories (e.g. snacks does picker + terminal + dashboard), pick the dominant one and add a comment if non-obvious.

## Where to look next

- [SETUP.md](SETUP.md) — install, prereqs, recovery
- [FEATURES.md](FEATURES.md) — what each feature does
- [KEYMAPS.md](KEYMAPS.md) — every keymap
- [CUSTOMIZATION.md](CUSTOMIZATION.md) — extension points for adding a language, theme tweak, etc.
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — common issues
