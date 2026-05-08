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
        -- VS Code-style preview slot: at most one buffer is "transient",
        -- replaced on the next preview open; explicit pin (`t`) keeps it,
        -- and editing the buffer auto-promotes it to pinned.
        local preview = { bufnr = nil }

        local function find_main_win()
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype ~= "neo-tree" then
                    return win
                end
            end
        end

        local function get_file_path(state)
            local node = state.tree:get_node()
            if not node or (node.type ~= "file" and node.type ~= "terminal") then
                return nil
            end
            local path = node.path or node:get_id()
            if not path or path == "" then
                return nil
            end
            return path
        end

        -- Mirror what filesystem/commands.lua does: hand the source's
        -- toggle_directory to common.toggle_node so dirs expand/collapse
        -- (and lazy-load children) the same way as the default `open` mapping.
        local function toggle_dir_if_node_is_dir(state)
            local node = state.tree:get_node()
            if not node or node.type ~= "directory" then
                return false
            end
            local cc = require("neo-tree.sources.common.commands")
            local fs = require("neo-tree.sources.filesystem")
            local utils = require("neo-tree.utils")
            cc.toggle_node(state, utils.wrap(fs.toggle_directory, state))
            return true
        end

        local function drop_old_preview(new_bufnr)
            local old = preview.bufnr
            if not old or old == new_bufnr then
                return
            end
            if not vim.api.nvim_buf_is_valid(old) or vim.bo[old].modified then
                return
            end
            for _, w in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(w) == old then
                    return -- still visible somewhere; don't kill
                end
            end
            pcall(Snacks.bufdelete, { buf = old })
        end

        local function open_preview(state)
            if toggle_dir_if_node_is_dir(state) then
                return
            end
            local path = get_file_path(state)
            if not path then
                return
            end
            local win = find_main_win()
            if not win then
                return
            end
            vim.api.nvim_set_current_win(win)
            vim.cmd("edit " .. vim.fn.fnameescape(path))
            local new_bufnr = vim.api.nvim_get_current_buf()
            drop_old_preview(new_bufnr)
            preview.bufnr = new_bufnr
        end

        local function open_pinned(state)
            if toggle_dir_if_node_is_dir(state) then
                return
            end
            local path = get_file_path(state)
            if not path then
                return
            end
            local win = find_main_win()
            if not win then
                return
            end
            vim.api.nvim_set_current_win(win)
            vim.cmd("edit " .. vim.fn.fnameescape(path))
            -- Pinning the current preview just promotes it.
            if preview.bufnr == vim.api.nvim_get_current_buf() then
                preview.bufnr = nil
            end
        end

        -- Promote preview to pinned as soon as the user edits it, so a
        -- subsequent preview-open won't silently discard their changes-in-progress.
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertEnter" }, {
            group = vim.api.nvim_create_augroup("NeoTreePreviewPromote", { clear = true }),
            callback = function(args)
                if preview.bufnr == args.buf then
                    preview.bufnr = nil
                end
            end,
        })

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
                    ["<cr>"] = "open_preview_slot",
                    ["l"] = "open_preview_slot",
                    ["h"] = "close_node",
                    ["t"] = "open_pinned",
                    ["P"] = { "toggle_preview", config = { use_float = true } },
                },
            },

            commands = {
                open_preview_slot = open_preview,
                open_pinned = open_pinned,
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
    end,
}
