# Neovim Configuration

A modern, modular Neovim configuration with powerful LSP support, built for efficient software development.

## Features

- **Cyberdream Theme** - Modern dark theme with transparent background
- **Fast Startup** - Lazy loading plugins with lazy.nvim
- **Telescope** - Fuzzy finder for files, text, and more
- **Neo-tree** - Feature-rich file explorer with git integration
- **LSP Support** - Full language server protocol integration
- **Auto-completion** - Intelligent completion with nvim-cmp
- **Debug Support** - DAP integration for Rust (CodeLLDB)
- **Syntax Highlighting** - Tree-sitter powered syntax highlighting
- **Status Line** - Custom lualine with mode, git branch, diagnostics, and diff indicators
- **Git Integration** - Fugitive, gitsigns, and commit message completions
- **Formatting** - Auto format-on-save with conform.nvim
- **Linting** - nvim-lint with eslint_d, ruff, markdownlint
- **Diagnostics** - trouble.nvim for structured diagnostics panel
- **Terminal** - Integrated floating terminal with toggleterm

## Language Support

| Language       | LSP           | Formatter          | Debugger | Features                    |
|----------------|---------------|--------------------|----------|-----------------------------|
| Rust           | rust-analyzer | rustfmt            | CodeLLDB | Macro expansion, cargo      |
| C/C++          | clangd        | clang-format       | -        | AST view, IWYU, clang-tidy  |
| JavaScript/TS  | vtsls         | prettierd/prettier | -        | Linting (eslint_d)          |
| Python         | -             | isort, black       | -        | Linting (ruff)              |
| Lua            | lua_ls        | stylua             | -        | Neovim API support          |
| JSON           | jsonls        | prettierd/prettier | -        | Schema validation           |
| Markdown       | marksman      | prettierd/prettier | -        | Linting (markdownlint)      |
| CMake          | neocmake      | cmake_format       | -        | Project detection           |
| Metal          | -             | clang-format       | -        | Treesitter via cpp parser   |
| RON            | -             | rustfmt            | -        | Syntax highlighting         |
| TOML           | -             | taplo              | -        | -                           |
| CSS/SCSS/HTML  | -             | prettierd/prettier | -        | -                           |
| YAML           | -             | prettierd/prettier | -        | -                           |

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
    ├── utils/
    │   └── key_mapper.lua      # Keymap utility
    └── plugins/                # Plugin specifications
        ├── coding/             # Coding tools
        │   ├── autopairs.lua   # Auto bracket pairing
        │   ├── comment.lua     # Code commenting
        │   └── completion.lua  # nvim-cmp completion
        ├── editor/             # Editor enhancements
        │   ├── telescope.lua   # Fuzzy finder
        │   ├── toggleterm.lua  # Terminal emulator
        │   └── trouble.lua     # Diagnostics panel
        ├── ui/                 # UI plugins
        │   ├── themes.lua      # Cyberdream theme
        │   ├── lualine.lua     # Status line
        │   ├── neo-tree.lua    # File explorer
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
        │   └── git.lua         # Git integration
        └── cord.lua            # Discord Rich Presence
```

## Key Bindings

### Global Keymaps

| Key              | Mode   | Description                    |
|------------------|--------|--------------------------------|
| `<Space>`        | -      | Leader key                     |
| `<C-h/j/k/l>`   | Normal | Navigate between splits        |
| `<leader>h`      | Normal | Clear search highlighting      |
| `<leader>s`      | Normal | Save file                      |
| `<leader>d`      | N / V  | Delete without clipboard       |
| `<leader>p`      | Visual | Paste without overwrite        |
| `< / >`          | Visual | Indent/outdent (keep selection)|

### File Navigation (Telescope)

| Key          | Description           |
|--------------|-----------------------|
| `<leader>ff` | Find files            |
| `<leader>fg` | Live grep (search)    |
| `<leader>fr` | Recent files          |
| `<leader>fb` | Find buffers          |
| `<leader>fh` | Find help tags        |

### File Explorer (Neo-tree)

| Key          | Description              |
|--------------|--------------------------|
| `<leader>e`  | Toggle file tree         |
| `<leader>o`  | Reveal current file      |
| `l`          | Open file/folder         |
| `h`          | Collapse folder          |
| `P`          | Preview in float         |

### LSP

| Key          | Description              |
|--------------|--------------------------|
| `K`          | Hover documentation      |
| `gd`         | Go to definition         |
| `gr`         | Go to references         |
| `gi`         | Go to implementation     |
| `<leader>rn` | Rename symbol            |
| `<leader>cc` | Show diagnostics float   |
| `<leader>ca` | Code actions             |
| `<leader>cf` | Format buffer            |
| `<leader>cm` | Open Mason               |

### Diagnostics (Trouble)

| Key          | Description                    |
|--------------|--------------------------------|
| `<leader>xx` | Toggle diagnostics panel       |
| `<leader>xd` | Buffer diagnostics only        |
| `<leader>xs` | Symbols outline                |
| `<leader>xq` | Quickfix list                  |
| `<leader>xl` | Location list                  |
| `[q / ]q`    | Previous/next item             |

### Git

| Key            | Description              |
|----------------|--------------------------|
| `<leader>gs`   | Git status               |
| `<leader>gb`   | Git blame                |
| `<leader>gd`   | Git diff                 |
| `<leader>gl`   | Git log                  |
| `<leader>gp`   | Git push                 |
| `<leader>gP`   | Git pull                 |
| `<leader>gc`   | Git commit               |
| `]h / [h`      | Next/prev hunk           |
| `<leader>ghs`  | Stage hunk               |
| `<leader>ghr`  | Reset hunk               |
| `<leader>ghS`  | Stage buffer             |
| `<leader>ghu`  | Undo stage hunk          |
| `<leader>ghR`  | Reset buffer             |
| `<leader>ghp`  | Preview hunk             |
| `<leader>ghi`  | Preview hunk inline      |
| `<leader>ghb`  | Blame line (full)        |
| `<leader>ghd`  | Diff this                |
| `<leader>ghD`  | Diff this ~              |
| `<leader>gtb`  | Toggle line blame        |
| `<leader>gtd`  | Toggle deleted           |

### Language-Specific

#### Rust
| Key          | Description              |
|--------------|--------------------------|
| `<leader>cR` | Rust code actions        |
| `<leader>dr` | Rust debuggables         |

#### C/C++
| Key          | Description              |
|--------------|--------------------------|
| `<leader>ch` | Switch source/header     |

### Terminal

| Key          | Description              |
|--------------|--------------------------|
| `<leader>t`  | Toggle floating terminal |
| `<C-x>`      | Close terminal           |

### Completion (Insert Mode)

| Key          | Description              |
|--------------|--------------------------|
| `<Tab>`      | Next item                |
| `<S-Tab>`    | Previous item            |
| `<C-n/p>`    | Next/previous item       |
| `<C-Space>`  | Trigger completion       |
| `<CR>`       | Confirm selection        |
| `<C-e>`      | Close completion         |
| `<C-f>`      | Scroll docs down         |
| `<C-S-f>`    | Scroll docs up           |

### Treesitter

| Key          | Description              |
|--------------|--------------------------|
| `<C-Space>`  | Init/increment selection |
| `<BS>`       | Decrement selection      |

## Installation

### Prerequisites

- Neovim >= 0.9.0
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
| codelldb        | Rust DAP debugger          |

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
brew install stylua

# Python
pip install isort black

# Rust/RON
rustup component add rustfmt     # comes with Rust toolchain

# TOML
brew install taplo
```

#### Linters

```bash
npm i -g eslint_d                # JavaScript/TypeScript
pip install ruff                 # Python
brew install markdownlint-cli    # Markdown
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

Add your custom keymaps to `lua/configs/keymaps.lua` using the `map_key` utility:
```lua
local map_key = require("utils.key_mapper").map_key
map_key("<leader>cc", ":YourCommand<CR>")
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
- [cyberdream.nvim](https://github.com/scottmckendry/cyberdream.nvim) - Color scheme
- All the amazing plugin authors in the Neovim community
