return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
        { "<leader>e", ":Neotree toggle<cr>", silent = true, desc = "Neo-tree toggle" },
        { "<leader>o", ":Neotree reveal<cr>", silent = true, desc = "Neo-tree reveal" },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    opts = {
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,

        default_component_configs = {
            container = { enable_character_fade = true },
            indent = {
                indent_size = 1,
                padding = 1,
                with_markers = true,
                indent_marker = "│",
                last_indent_marker = "└",
                highlight = "NeoTreeIndentMarker",
                with_expanders = true,
                expander_collapsed = "",
                expander_expanded = "",
            },
            icon = {
                folder_closed = "",
                folder_open = "",
                folder_empty = "󰜌",
                default = "󰈚",
                highlight = "NeoTreeFileIcon",
            },
            modified = {
                symbol = "✿",
                highlight = "NeoTreeModified",
            },
            -- Mirror fish-theme-damin's git glyphs (Dingbats only, no nerd-font
            -- dependency): ✓ staged, ✗ modified/deleted, ? untracked, ⇣ unstaged.
            git_status = {
                symbols = {
                    added = "✓",
                    modified = "✗",
                    deleted = "✗",
                    renamed = "→",
                    untracked = "?",
                    ignored = "·",
                    unstaged = "⇣",
                    staged = "✓",
                    conflict = "✦",
                },
            },
        },

        -- Floating window: opens centered as a popup, auto-closes on file
        -- open. No sidebar, no bufferline offset, no main-window juggling.
        window = {
            position = "float",
            popup = {
                size = { height = "85%", width = "85%" },
                position = "50%",
            },
            mapping_options = { noremap = true, nowait = true },
            mappings = {
                ["<space>"] = "none",
                ["<cr>"] = "open_tabnew_float",
                ["l"] = "open_tabnew_float",
                ["h"] = "close_node",
            },
        },

        -- Workaround for neo-tree utils/init.lua:854 invalid-winid in float mode.
        commands = {
            open_tabnew_float = function(state)
                local node = state.tree:get_node()
                if require("neo-tree.utils").is_expandable(node) then
                    return require("neo-tree.sources.common.commands").toggle_node(
                        state,
                        require("neo-tree.sources.filesystem").toggle_directory
                    )
                end
                require("neo-tree.command").execute({ action = "close" })
                vim.cmd("tabnew " .. vim.fn.fnameescape(node:get_id()))
            end,
        },

        filesystem = {
            filtered_items = {
                visible = false,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_by_name = {
                    ".git",
                    ".DS_Store",
                    "thumbs.db",
                    "node_modules",
                    "__pycache__",
                    ".idea",
                    ".vscode",
                    ".ruff_cache",
                },
            },
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
        },
    },
}
