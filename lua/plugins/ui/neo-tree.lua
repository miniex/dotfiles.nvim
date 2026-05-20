local damin_pink = "#E890B0"

-- damin polish: pink float border + pink "currently editing" file.
local function apply_hl()
    vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { fg = damin_pink, bg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { fg = damin_pink, bold = true })
    vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", { fg = damin_pink, italic = true, bold = true })
end
apply_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("NeoTreeDaminHL", { clear = true }),
    callback = apply_hl,
})

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
        -- "NC" is neo-tree's default; the actual flower border is set via
        -- window.popup.border.style below (the official path through nui.nvim).
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,

        default_component_configs = {
            container = { enable_character_fade = true },
            indent = {
                indent_size = 1,
                padding = 1,
                with_markers = true,
                indent_marker = "┊",
                last_indent_marker = "╰",
                highlight = "NeoTreeIndentMarker",
                with_expanders = true,
                expander_collapsed = "❯",
                expander_expanded = "❮",
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
            name = {
                trailing_slash = true,
                use_git_status_colors = true,
            },
            -- Dingbats only — mirrors fish-theme-damin, no nerd-font dependency.
            git_status = {
                symbols = {
                    added = "✦",
                    modified = "✿",
                    deleted = "✗",
                    renamed = "❀",
                    untracked = "❁",
                    ignored = "·",
                    unstaged = "✧",
                    staged = "✓",
                    conflict = "✺",
                },
            },
        },

        window = {
            position = "float",
            popup = {
                border = {
                    style = vim.g.flower_border,
                    text = { top = vim.g.flower_title("files"), top_align = "center" },
                },
                -- Function callbacks track the shared modal-geom rectangle
                -- on every open (resolve_config_option re-evaluates each time).
                size = function()
                    local mg = require("config.modal-geom")
                    return { width = mg.inner_width(), height = mg.inner_height() }
                end,
                position = function()
                    -- +1 cancels nui's half-border position adjustment.
                    local mg = require("config.modal-geom")
                    return { row = mg.row() + 1, col = mg.col() + 1 }
                end,
            },
            mapping_options = { noremap = true, nowait = true },
            mappings = {
                ["<space>"] = "none",
                ["<cr>"] = "open_tabnew_float",
                ["l"] = "open_tabnew_float",
                ["h"] = "close_node",
            },
        },

        -- Float mode: neo-tree's open commands hit invalid winid; close + tabnew instead.
        commands = {
            open_tabnew_float = function(state)
                local utils = require("neo-tree.utils")
                local node = state.tree:get_node()
                if utils.is_expandable(node) then
                    local fs = require("neo-tree.sources.filesystem")
                    return require("neo-tree.sources.common.commands").toggle_node(
                        state,
                        utils.wrap(fs.toggle_directory, state)
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
