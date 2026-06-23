-- Buffer-as-filesystem editing: rename / move / delete via normal-mode edits (LSP-aware).
-- default_file_explorer = false so it never hijacks directory buffers — `nvim <dir>`
-- still lands on the dashboard (dir-launch flow in snacks.lua / autocmds.lua).
return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
        { "<leader>O", "<cmd>Oil<cr>", desc = "Oil (edit dir as buffer)" },
    },
    opts = {
        default_file_explorer = false,
        -- Trash instead of unrecoverable delete (needs gio / trash-cli).
        delete_to_trash = true,
        view_options = { show_hidden = true },
        keymaps = {
            ["q"] = "actions.close",
        },
    },
}
