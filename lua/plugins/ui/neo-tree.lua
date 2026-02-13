local map_key = require("utils.key_mapper").map_key

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- Required for file icons
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
        -- Modern Diagnostic Signs
        local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = "󰋽 " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        require("neo-tree").setup({
            close_if_last_window = true,
            popup_border_style = "rounded",
            enable_git_status = true,
            enable_diagnostics = true,

            default_component_configs = {
                container = { enable_character_fade = true },
                indent = {
                    indent_size = 2,
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
                    highlight = "NeoTreeFileIcon"
                },
                modified = {
                    symbol = "●", -- Simple dot for modified files
                    highlight = "NeoTreeModified",
                },
                git_status = {
                    symbols = {
                        -- Change type
                        added     = "✚",
                        modified  = "",
                        deleted   = "✖",
                        renamed   = "󰁕",
                        -- Status type
                        untracked = "",
                        ignored   = "",
                        unstaged  = "󰄱",
                        staged    = "",
                        conflict  = "",
                    }
                },
            },

            window = {
                position = "left",
                width = 35,
                mapping_options = { noremap = true, nowait = true },
                mappings = {
                    ["<space>"] = "none",
                    ["l"] = "open",       -- Better navigation: l to open
                    ["h"] = "close_node", -- Better navigation: h to collapse
                    ["P"] = { "toggle_preview", config = { use_float = true } },
                }
            },

            filesystem = {
                filtered_items = {
                    visible = false,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    hide_by_name = {
                        ".git", ".DS_Store", "thumbs.db", "node_modules", "__pycache__"
                    },
                },
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
            },
        })

        -- Modern Keybindings
        map_key("<leader>e", ":Neotree toggle<cr>")
        map_key("<leader>o", ":Neotree reveal<cr>")
    end,
}
