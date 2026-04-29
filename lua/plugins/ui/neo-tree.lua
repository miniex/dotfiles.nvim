return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- File icons with brand colors
        "MunifTanjim/nui.nvim",
        {
            "s1n7ax/nvim-window-picker",
            version = "2.*",
            config = function()
                require("window-picker").setup({
                    filter_rules = {
                        include_current_win = false,
                        autoselect_one = true,
                        bo = {
                            filetype = { "neo-tree", "neo-tree-popup", "notify" },
                            buftype = { "terminal", "quickfix" },
                        },
                    },
                })
            end,
        },
    },
    config = function()
        require("neo-tree").setup({
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
                    with_expanders = true, -- Adds arrows for folders
                    expander_collapsed = "",
                    expander_expanded = "",
                },
                icon = {
                    folder_closed = "",
                    folder_open = "",
                    folder_empty = "󰜌",
                    -- The "default" icon for unknown files
                    default = "󰈚",
                    highlight = "NeoTreeFileIcon",
                },
                modified = {
                    symbol = "●", -- Simple dot for modified files
                    highlight = "NeoTreeModified",
                },
                git_status = {
                    symbols = {
                        -- Change type
                        added = "✚",
                        modified = "",
                        deleted = "✖",
                        renamed = "󰁕",
                        -- Status type
                        untracked = "",
                        ignored = "",
                        unstaged = "󰄱",
                        staged = "",
                        conflict = "",
                    },
                },
            },

            window = {
                position = "left",
                width = 70,
                mapping_options = { noremap = true, nowait = true },
                mappings = {
                    ["<space>"] = "none",
                    ["l"] = "open", -- Better navigation: l to open
                    ["h"] = "close_node", -- Better navigation: h to collapse
                    ["P"] = { "toggle_preview", config = { use_float = true } },
                },
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
                    },
                },
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
            },
        })

        vim.keymap.set("n", "<leader>e", ":Neotree toggle<cr>", { silent = true })
        vim.keymap.set("n", "<leader>o", ":Neotree reveal<cr>", { silent = true })
    end,
}
