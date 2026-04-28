# Neovim Configuration

A modern, modular Neovim configuration with powerful LSP support, built for efficient software development.

## Features

- **Cyberdream Theme** - Modern dark theme with transparent background
- **Fast Startup** - Lazy loading plugins with lazy.nvim
- **Telescope** - Fuzzy finder for files, text, and more
- **Neo-tree** - Feature-rich file explorer with git integration
- **LSP Support** - Full language server protocol integration
- **Auto-completion** - Intelligent completion with nvim-cmp
- **Debug Support** - nvim-dap with UI + virtual text; adapters for Rust (CodeLLDB), C/C++ (cpptools), Python (debugpy)
- **Syntax Highlighting** - Tree-sitter powered syntax highlighting
- **Status Line** - Custom lualine with mode, git branch, diagnostics, and diff indicators
- **Git Integration** - Fugitive, gitsigns, and commit message completions
- **Formatting** - Auto format-on-save with conform.nvim
- **Linting** - nvim-lint with eslint_d, ruff, markdownlint (runs on save, not while typing)
- **Diagnostics** - trouble.nvim for structured diagnostics panel (deferred until normal mode for performance)
- **Terminal** - Integrated floating terminal with toggleterm
- **Auto Buffer Cleanup** - Automatically closes hidden buffers after 1 minute of inactivity to reduce memory usage
- **Keymap Discovery** - which-key.nvim popup hints when leader is held
- **Fast Motion** - flash.nvim label-based jumping (`s` / `S`) with treesitter integration
- **TODO Highlighting** - todo-comments.nvim for `TODO` / `FIXME` / `HACK` markers, searchable via Telescope/Trouble
- **Lua Dev** - lazydev.nvim provides Neovim runtime types for editing this very config
- **QoL Bundle** - snacks.nvim modules: notifier, indent guides, statuscolumn, LSP word highlight, smarter buffer delete, bigfile optimization
- **Animations** - snacks.scroll smooth scrolling, snacks.dim inactive-code dim, smear-cursor.nvim cursor trail, mini.animate window resize/open/close
- **Inline Images** - snacks.image renders images, GIFs, video previews and LaTeX math via Kitty graphics protocol (Markdown / HTML / LaTeX)

## Language Support

| Language       | LSP           | Formatter          | Debugger | Features                    |
|----------------|---------------|--------------------|----------|-----------------------------|
| Rust           | rust-analyzer       | rustfmt            | CodeLLDB | Macro expansion, cargo, crates.nvim |
| C/C++          | clangd              | clang-format       | cpptools | AST view, IWYU, clang-tidy          |
| JavaScript/TS  | vtsls               | prettierd/prettier | -        | Linting (eslint_d)                  |
| Python         | basedpyright + ruff | ruff (via LSP)     | debugpy  | Type check, lint, import sort       |
| Lua            | lua_ls              | stylua             | -        | Neovim API via lazydev              |
| JSON           | jsonls              | prettierd/prettier | -        | Schema validation                   |
| Markdown       | marksman            | prettierd/prettier | -        | Linting (markdownlint)              |
| CMake          | neocmake            | cmake_format       | -        | Project detection                   |
| Metal          | -                   | clang-format       | -        | Treesitter via cpp parser           |
| RON            | -                   | rustfmt            | -        | Syntax highlighting                 |
| TOML           | taplo               | taplo              | -        | Schema validation, hover            |
| CSS/SCSS       | cssls               | prettierd/prettier | -        | Validation, lint                    |
| HTML           | html + emmet_ls     | prettierd/prettier | -        | Emmet expansions                    |
| YAML           | yamlls              | prettierd/prettier | -        | SchemaStore validation              |

## Directory Structure

```
~/.config/nvim/
├── init.lua                    # Main entry point
├── stylua.toml                 # Lua formatter config
└── lua/
    ├── configs/                # Core configurations
    │   ├── globals.lua         # Leader keys
    │   ├── options.lua         # Vim options
    │   ├── keymaps.lua         # Global keymaps
    │   └── diagnostic.lua      # Diagnostic settings
    └── plugins/                # Plugin specifications
        ├── coding/             # Coding tools
        │   ├── autopairs.lua   # Auto bracket pairing
        │   ├── comment.lua     # Code commenting
        │   └── completion.lua  # nvim-cmp completion
        ├── editor/             # Editor enhancements
        │   ├── telescope.lua   # Fuzzy finder
        │   ├── toggleterm.lua  # Terminal emulator
        │   ├── trouble.lua     # Diagnostics panel
        │   ├── which-key.lua   # Keymap discovery popup
        │   ├── flash.lua       # s/S motion + treesitter jump
        │   └── todo-comments.lua # TODO/FIXME highlight + search
        ├── ui/                 # UI plugins
        │   ├── themes.lua      # Cyberdream theme
        │   ├── lualine.lua     # Status line
        │   ├── neo-tree.lua    # File explorer
        │   ├── devicons.lua    # File icons (nvim-web-devicons)
        │   ├── snacks.lua      # QoL bundle (notifier, indent, scroll, dim, ...)
        │   ├── smear-cursor.lua # Cursor smear/trail effect
        │   ├── mini-animate.lua # Window resize/open/close animations
        │   └── alpha.lua       # Dashboard
        ├── lang/               # Language configs
        │   ├── lsp.lua         # LSP setup (Mason + lspconfig)
        │   ├── treesitter.lua  # Syntax highlighting
        │   ├── conform.lua     # Formatters
        │   ├── lint.lua        # Linters (nvim-lint)
        │   ├── rust.lua        # Rust support
        │   ├── c-cpp.lua       # C/C++ support
        │   ├── cmake.lua       # CMake support
        │   ├── lua.lua         # Lua support
        │   ├── json.lua        # JSON support
        │   ├── markdown.lua    # Markdown support
        │   ├── metal.lua       # Metal shading language
        │   ├── ron.lua         # RON syntax
        │   ├── toml.lua        # TOML LSP (taplo)
        │   ├── python.lua      # Python LSP (basedpyright + ruff) + DAP
        │   ├── web.lua         # CSS / HTML / Emmet LSPs
        │   ├── yaml.lua        # YAML LSP with SchemaStore
        │   ├── dap.lua         # nvim-dap base + UI + mason adapters
        │   └── git.lua         # Git integration
        └── cord.lua            # Discord Rich Presence
```

## Key Bindings

> Leader key: `<Space>`

### Global (`configs/keymaps.lua`)

| Key            | Mode     | Description                     |
|----------------|----------|---------------------------------|
| `<C-h/j/k/l>` | Normal   | Navigate between splits         |
| `<leader>h`    | Normal   | Clear search highlighting       |
| `<leader>s`    | Normal   | Save file                       |
| `<leader>d`    | N / V    | Delete without yanking          |
| `<leader>p`    | Visual   | Paste without overwriting register |
| `< / >`        | Visual   | Indent/outdent (keep selection) |

### File Navigation — Telescope (`plugins/editor/telescope.lua`)

| Key          | Description        |
|--------------|--------------------|
| `<leader>ff` | Find files         |
| `<leader>fg` | Live grep (search) |
| `<leader>fr` | Recent files       |
| `<leader>fb` | Find buffers       |
| `<leader>fh` | Find help tags     |

### File Explorer — Neo-tree (`plugins/ui/neo-tree.lua`)

| Key         | Description         |
|-------------|---------------------|
| `<leader>e` | Toggle file tree    |
| `<leader>o` | Reveal current file |
| `l`         | Open file/folder    |
| `h`         | Collapse folder     |
| `P`         | Preview in float    |

### LSP (`plugins/lang/lsp.lua`)

| Key          | Description            |
|--------------|------------------------|
| `K`          | Hover documentation    |
| `gd`         | Go to definition       |
| `gr`         | Go to references       |
| `gi`         | Go to implementation   |
| `<leader>rn` | Rename symbol          |
| `<leader>cc` | Show diagnostics float |
| `<leader>ca` | Code actions           |
| `<leader>cf` | Format buffer (async)  |
| `<leader>cm` | Open Mason             |

### Diagnostics — Trouble (`plugins/editor/trouble.lua`)

| Key          | Description              |
|--------------|--------------------------|
| `<leader>xx` | Toggle diagnostics panel |
| `<leader>xd` | Buffer diagnostics only  |
| `<leader>xs` | Symbols outline          |
| `<leader>xq` | Quickfix list            |
| `<leader>xl` | Location list            |
| `<leader>xt` | TODO list (Trouble)      |
| `<leader>xT` | TODO/FIX/FIXME (Trouble) |
| `[q`         | Previous item            |
| `]q`         | Next item                |

### Motion — Flash (`plugins/editor/flash.lua`)

| Key      | Mode      | Description                         |
|----------|-----------|-------------------------------------|
| `s`      | N / X / O | Flash jump (search + label)         |
| `S`      | N / X / O | Treesitter-based jump               |
| `r`      | Op-pending| Remote flash (operate at distance)  |
| `R`      | Op / X    | Treesitter search                   |
| `<C-s>`  | Cmdline   | Toggle flash inside `/` `?` search  |

### TODO Comments (`plugins/editor/todo-comments.lua`)

| Key          | Description                |
|--------------|----------------------------|
| `]t`         | Next TODO comment          |
| `[t`         | Previous TODO comment      |
| `<leader>ft` | Find todos via Telescope   |

### Keymap Discovery — which-key (`plugins/editor/which-key.lua`)

| Key          | Description                          |
|--------------|--------------------------------------|
| `<leader>?`  | Show buffer-local keymaps            |
| `<leader>`   | Hold to popup all leader keymaps     |

### QoL — Snacks (`plugins/ui/snacks.lua`)

| Key          | Mode    | Description                            |
|--------------|---------|----------------------------------------|
| `<leader>bd` | Normal  | Smart buffer delete                    |
| `<leader>cn` | Normal  | Notification history                   |
| `<leader>un` | Normal  | Dismiss all notifications              |
| `]]`         | N / T   | Next reference (LSP word highlight)    |
| `[[`         | N / T   | Previous reference                     |

### Git — Fugitive (`plugins/lang/git.lua`)

| Key          | Description |
|--------------|-------------|
| `<leader>gs` | Git status  |
| `<leader>gb` | Git blame   |
| `<leader>gd` | Git diff    |
| `<leader>gl` | Git log     |
| `<leader>gp` | Git push    |
| `<leader>gP` | Git pull    |
| `<leader>gc` | Git commit  |

### Git — Gitsigns (`plugins/lang/git.lua`)

| Key           | Mode   | Description          |
|---------------|--------|----------------------|
| `]h`          | Normal | Next hunk            |
| `[h`          | Normal | Previous hunk        |
| `<leader>ghs` | N / V  | Stage hunk           |
| `<leader>ghr` | N / V  | Reset hunk           |
| `<leader>ghS` | Normal | Stage buffer         |
| `<leader>ghu` | Normal | Undo stage hunk      |
| `<leader>ghR` | Normal | Reset buffer         |
| `<leader>ghp` | Normal | Preview hunk         |
| `<leader>ghi` | Normal | Preview hunk inline  |
| `<leader>ghb` | Normal | Blame line (full)    |
| `<leader>ghd` | Normal | Diff this            |
| `<leader>ghD` | Normal | Diff this ~          |
| `<leader>gtb` | Normal | Toggle line blame    |
| `<leader>gtd` | Normal | Toggle deleted       |

### Rust (`plugins/lang/rust.lua`)

| Key          | Description        |
|--------------|--------------------|
| `<leader>cR` | Rust code actions  |
| `<leader>dr` | Rust debuggables (rustaceanvim) |

### Debugger — DAP (`plugins/lang/dap.lua`)

| Key           | Description                       |
|---------------|-----------------------------------|
| `<leader>db`  | Toggle breakpoint                 |
| `<leader>dB`  | Conditional breakpoint            |
| `<leader>dc`  | Continue / start                  |
| `<leader>dC`  | Run to cursor                     |
| `<leader>di`  | Step into                         |
| `<leader>dO`  | Step over                         |
| `<leader>do`  | Step out                          |
| `<leader>dl`  | Run last                          |
| `<leader>dp`  | Pause                             |
| `<leader>dr`  | Toggle REPL                       |
| `<leader>ds`  | Show session                      |
| `<leader>dt`  | Terminate                         |
| `<leader>du`  | Toggle DAP UI                     |
| `<leader>dPt` | (Python) Debug test method        |
| `<leader>dPc` | (Python) Debug test class         |

### C/C++ (`plugins/lang/c-cpp.lua`)

| Key          | Description          |
|--------------|----------------------|
| `<leader>ch` | Switch source/header |

### Terminal (`plugins/editor/toggleterm.lua`)

| Key         | Mode     | Description              |
|-------------|----------|--------------------------|
| `<leader>t` | Normal   | Toggle floating terminal |
| `<C-x>`     | N / T    | Close terminal           |

### Completion — nvim-cmp (`plugins/coding/completion.lua`)

| Key         | Mode   | Description          |
|-------------|--------|----------------------|
| `<Tab>`     | Insert | Next item            |
| `<S-Tab>`   | Insert | Previous item        |
| `<C-n>`     | Insert | Next item            |
| `<C-p>`     | Insert | Previous item        |
| `<C-Space>` | Insert | Trigger completion   |
| `<CR>`      | Insert | Confirm selection    |
| `<C-e>`     | Insert | Close completion     |
| `<C-f>`     | Insert | Scroll docs down     |
| `<C-S-f>`   | Insert | Scroll docs up       |

### Treesitter (`plugins/lang/treesitter.lua`)

| Key         | Description                    |
|-------------|--------------------------------|
| `<C-Space>` | Init/increment node selection  |
| `<BS>`      | Decrement node selection       |

## Installation

### Prerequisites

- Neovim >= 0.11.0 (uses `vim.diagnostic.config({ signs = { text = ... } })` and `vim.lsp.buf.hover({ border = ... })`)
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (for icons)
- C compiler (`gcc` or `clang`) + `make` (for telescope-fzf-native, LuaSnip)
- ripgrep (for Telescope live grep)
- Node.js & npm (for LSP servers, JS/TS tools)
- Python 3 & pip (for Python linters/formatters)
- Rust toolchain via [rustup](https://rustup.rs/) (for rustfmt, rust-analyzer)

### Install

1. **Backup your existing config:**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   mv ~/.local/share/nvim ~/.local/share/nvim.backup
   ```

2. **Clone this configuration:**
   ```bash
   git clone https://github.com/yourusername/dotfiles.nvim.git ~/.config/nvim
   ```

3. **Launch Neovim:**
   ```bash
   nvim
   ```
   Lazy.nvim will automatically install all plugins on first launch.

4. **Install language servers:**
   - Open Neovim and run `:Mason`
   - All configured servers will be automatically installed via Mason

### Mason Auto-installed (LSP servers & DAP)

These are installed automatically via Mason on first launch:

| Tool            | Purpose                    |
|-----------------|----------------------------|
| clangd          | C/C++ LSP                  |
| neocmake        | CMake LSP                  |
| vtsls           | JavaScript/TypeScript LSP  |
| jsonls          | JSON LSP                   |
| lua-language-server | Lua LSP              |
| marksman        | Markdown LSP               |
| rust-analyzer   | Rust LSP                   |
| taplo           | TOML LSP / formatter       |
| basedpyright    | Python LSP (types)         |
| ruff            | Python LSP (lint/format)   |
| css-lsp         | CSS/SCSS LSP               |
| html-lsp        | HTML LSP                   |
| emmet-ls        | Emmet expansions           |
| yaml-language-server | YAML LSP              |
| codelldb        | Rust DAP debugger          |
| cpptools        | C/C++ DAP debugger         |
| debugpy         | Python DAP debugger        |

### External Tools

Formatters and linters that need to be installed separately:

#### Formatters

```bash
# C/C++/Metal
brew install clang-format

# CMake
pip install cmakelang            # provides cmake_format

# JavaScript/TypeScript/CSS/HTML/JSON/Markdown/YAML
npm i -g @fsouza/prettierd       # prettierd (preferred)
npm i -g prettier                # prettier (fallback)

# Lua
brew install stylua            # macOS
cargo install stylua           # any platform with Rust toolchain

# Python — formatter/linter handled by ruff LSP (auto-installed via Mason)

# Rust/RON
rustup component add rustfmt     # comes with Rust toolchain

# TOML
brew install taplo
```

#### Linters

```bash
npm i -g eslint_d                # JavaScript/TypeScript
brew install markdownlint-cli    # Markdown
# Python lint via ruff LSP (auto-installed via Mason)
```

### WSL2 Clipboard Integration

If you're using WSL2, clipboard integration is automatically configured in `init.lua` to use Windows clipboard via `clip.exe`.

## Customization

### Adding a New Language

1. Create a new file in `lua/plugins/lang/`:
   ```lua
   -- lua/plugins/lang/mylang.lua
   return {
     {
       "neovim/nvim-lspconfig",
       opts = {
         servers = {
           mylang_ls = {
             -- LSP settings here
           },
         },
       },
     },
   }
   ```

2. Add formatter to `lua/plugins/lang/conform.lua`:
   ```lua
   formatters_by_ft = {
     mylang = { "my_formatter" },
   },
   ```

3. Add linter to `lua/plugins/lang/lint.lua`:
   ```lua
   lint.linters_by_ft = {
     mylang = { "my_linter" },
   }
   ```

### Changing Theme

Edit `lua/plugins/ui/themes.lua` to use a different colorscheme, or customize the Cyberdream theme colors.

### Custom Keymaps

Add your custom keymaps to `lua/configs/keymaps.lua` using the local `map` helper or `vim.keymap.set` directly:
```lua
-- via the local helper defined at the top of keymaps.lua
map("<leader>cc", ":YourCommand<CR>")

-- or call the API directly
vim.keymap.set("n", "<leader>cc", ":YourCommand<CR>", { noremap = true, silent = true })
```

## Configuration Philosophy

- **Modular:** Each plugin has its own file for easy management
- **Lazy Loading:** Plugins load only when needed for fast startup
- **Minimal:** Only essential plugins, no bloat
- **LSP-First:** Built around Language Server Protocol for IDE features
- **Performance:** Optimized for speed with disabled default plugins

## Troubleshooting

### LSP not working

1. Check if the language server is installed: `:Mason`
2. Check LSP status: `:LspInfo`
3. View logs: `:LspLog`

### Formatters not working

1. Ensure the formatter is installed via Mason or system package manager
2. Check Conform status: `:ConformInfo`
3. Verify formatter is configured in `conform.lua`

### Linters not working

1. Ensure the linter binary is installed and in `$PATH`
2. Check configured linters in `lint.lua`

### Treesitter errors

1. Update parsers: `:TSUpdate`
2. Check installation: `:TSInstallInfo`

## Acknowledgments

- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configurations
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [trouble.nvim](https://github.com/folke/trouble.nvim) - Diagnostics panel
- [nvim-lint](https://github.com/mfussenegger/nvim-lint) - Async linting
- [conform.nvim](https://github.com/stevearc/conform.nvim) - Formatter
- [snacks.nvim](https://github.com/folke/snacks.nvim) - QoL bundle
- [which-key.nvim](https://github.com/folke/which-key.nvim) - Keymap discovery
- [flash.nvim](https://github.com/folke/flash.nvim) - Label-based motion
- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) - TODO highlighting
- [lazydev.nvim](https://github.com/folke/lazydev.nvim) - Lua dev types
- [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) - Cursor smear effect
- [mini.animate](https://github.com/echasnovski/mini.nvim) - Window animations
- [cyberdream.nvim](https://github.com/scottmckendry/cyberdream.nvim) - Color scheme
- All the amazing plugin authors in the Neovim community
