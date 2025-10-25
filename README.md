# Neovim Configuration

A modern, modular Neovim configuration with powerful LSP support, built for efficient software development.

## Features

- **Cyberdream Theme** - Modern dark theme with transparent background
- **Fast Startup** - Lazy loading plugins with lazy.nvim
- **Telescope** - Fuzzy finder for files, text, and more
- **Neo-tree** - Feature-rich file explorer with git integration
- **LSP Support** - Full language server protocol integration
- **Auto-completion** - Intelligent completion with nvim-cmp
- **Debug Support** - DAP integration for Python and Rust
- **Syntax Highlighting** - Tree-sitter powered syntax highlighting
- **Git Integration** - Status indicators and commit message completions
- **Terminal** - Integrated floating terminal with toggleterm

## Language Support

| Language       | LSP           | Formatter          | Debugger | Features                    |
|----------------|---------------|--------------------|----------|-----------------------------|
| Python         | Pyright, Ruff | black, isort       | debugpy  | Import org, linting         |
| Rust           | rust-analyzer | rustfmt            | CodeLLDB | Macro expansion, cargo      |
| JavaScript/TS  | VTSLS         | prettier           | -        | Import management           |
| C/C++          | clangd        | clang-format       | -        | AST view, IWYU              |
| CMake          | neocmake      | cmake_format       | -        | Project detection           |
| Lua            | lua_ls        | stylua             | -        | Neovim API support          |
| JSON           | jsonls        | prettier           | -        | Schema validation           |
| Markdown       | marksman      | prettier           | -        | Navigation                  |
| Tailwind CSS   | tailwindcss   | -                  | -        | Class completion            |

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
        │   └── toggleterm.lua  # Terminal emulator
        ├── ui/                 # UI plugins
        │   ├── themes.lua      # Cyberdream theme
        │   ├── lualine.lua     # Status line
        │   ├── neo-tree.lua    # File explorer
        │   └── alpha.lua       # Dashboard
        ├── lang/               # Language configs
        │   ├── lsp.lua         # LSP setup
        │   ├── treesitter.lua  # Syntax highlighting
        │   ├── conform.lua     # Formatters
        │   ├── python.lua      # Python support
        │   ├── rust.lua        # Rust support
        │   ├── javascript.lua  # JS/TS support
        │   ├── c-cpp.lua       # C/C++ support
        │   ├── cmake.lua       # CMake support
        │   ├── lua.lua         # Lua support
        │   ├── json.lua        # JSON support
        │   ├── markdown.lua    # Markdown support
        │   ├── tailwind.lua    # Tailwind CSS
        │   └── git.lua         # Git integration
        └── cord.lua            # Discord Rich Presence
```

## Key Bindings

### Global Keymaps

| Key                  | Mode   | Description                    |
|----------------------|--------|--------------------------------|
| `<Space>`            | -      | Leader key                     |
| `<C-h/j/k/l>`        | Normal | Navigate between splits        |
| `<leader>h`          | Normal | Clear search highlighting      |
| `<leader>s`          | Normal | Save file                      |
| `<leader>d`          | Normal | Delete without clipboard       |
| `<leader>p`          | Visual | Paste without overwrite        |
| `< / >`              | Visual | Indent/outdent (keep selection)|

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
| `\`          | Reveal current file      |

### LSP

| Key          | Description              |
|--------------|--------------------------|
| `K`          | Hover documentation      |
| `gd`         | Go to definition         |
| `gr`         | Go to references         |
| `gi`         | Go to implementation     |
| `<leader>rn` | Rename symbol            |
| `<leader>cc` | Show diagnostics         |
| `<leader>ca` | Code actions             |
| `<leader>cf` | Format buffer            |

### Language-Specific

#### JavaScript/TypeScript
| Key          | Description              |
|--------------|--------------------------|
| `gD`         | Go to source definition  |
| `gR`         | All file references      |
| `<leader>co` | Organize imports         |
| `<leader>cM` | Add missing imports      |
| `<leader>cu` | Remove unused imports    |

#### Rust
| Key          | Description              |
|--------------|--------------------------|
| `<leader>cR` | Rust code actions        |
| `<leader>dr` | Rust debuggables         |

#### C/C++
| Key          | Description              |
|--------------|--------------------------|
| `<leader>ch` | Switch source/header     |

#### Python
| Key          | Description              |
|--------------|--------------------------|
| `<leader>dPt`| Debug test method        |
| `<leader>dPc`| Debug test class         |

### Terminal

| Key          | Description              |
|--------------|--------------------------|
| `<leader>t`  | Toggle floating terminal |
| `<C-\><C-n>` | Exit terminal mode       |

### Completion (Insert Mode)

| Key          | Description              |
|--------------|--------------------------|
| `<Tab>`      | Next item                |
| `<S-Tab>`    | Previous item            |
| `<C-Space>` | Trigger completion       |
| `<CR>`       | Confirm selection        |
| `<C-e>`      | Close completion         |
| `<C-f>`      | Scroll docs down         |
| `<C-S-f>`    | Scroll docs up           |

## Installation

### Prerequisites

- Neovim >= 0.9.0
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (for icons)
- ripgrep (for Telescope live grep)
- Node.js (for some LSP servers)

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

### WSL2 Clipboard Integration

If you're using WSL2, clipboard integration is automatically configured in `init.lua` to use Windows clipboard via `win32yank.exe`.

## Customization

### Adding a New Language

1. Create a new file in `lua/plugins/lang/`:
   ```lua
   -- lua/plugins/lang/mylang.lua
   return {
     {
       "williamboman/mason.nvim",
       opts = function(_, opts)
         opts.ensure_installed = opts.ensure_installed or {}
         vim.list_extend(opts.ensure_installed, { "mylang-ls" })
       end,
     },
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

### Changing Theme

Edit `lua/plugins/ui/themes.lua` to use a different colorscheme, or customize the Cyberdream theme colors.

### Custom Keymaps

Add your custom keymaps to `lua/configs/keymaps.lua` using the `map()` utility:
```lua
map("n", "<leader>cc", ":YourCommand<CR>", "Your description")
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

1. Ensure the formatter is installed via Mason
2. Check Conform status: `:ConformInfo`
3. Verify formatter is configured in `conform.lua`

### Treesitter errors

1. Update parsers: `:TSUpdate`
2. Check installation: `:TSInstallInfo`

## License

This configuration is free to use and modify. Feel free to fork and customize to your needs!

## Acknowledgments

- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP configurations
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy finder
- [cyberdream.nvim](https://github.com/scottmckendry/cyberdream.nvim) - Color scheme
- All the amazing plugin authors in the Neovim community

## Contributing

Issues and pull requests are welcome! Feel free to suggest improvements or report bugs.
