return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { ensure_installed = { "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes" } },
    },
    { "petertriho/cmp-git", opts = {} },
    {
        "hrsh7th/nvim-cmp",
        optional = true,
        dependencies = {
            { "petertriho/cmp-git", opts = {} },
        },
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, { name = "git" })
        end,
    },

    -- Fugitive: Git wrapper for Neovim
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G", "Gstatus", "Gblame", "Gpush", "Gpull", "Gdiff", "Glog" },
        keys = {
            { "<leader>gs", "<cmd>Git<cr>",               desc = "Git Status" },
            { "<leader>gb", "<cmd>Git blame<cr>",         desc = "Git Blame" },
            { "<leader>gd", "<cmd>Gdiffsplit<cr>",        desc = "Git Diff" },
            { "<leader>gl", "<cmd>Git log --oneline<cr>", desc = "Git Log" },
            { "<leader>gp", "<cmd>Git push<cr>",          desc = "Git Push" },
            { "<leader>gP", "<cmd>Git pull<cr>",          desc = "Git Pull" },
            { "<leader>gc", "<cmd>Git commit<cr>",        desc = "Git Commit" },
        },
    },

    -- Gitsigns: Show git changes in the gutter
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol",
                delay = 300,
            },
            current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
            word_diff = true,
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            signs_staged = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end

                -- Navigation
                map("n", "]h", gs.next_hunk, "Next Hunk")
                map("n", "[h", gs.prev_hunk, "Prev Hunk")

                -- Actions
                map("n", "<leader>ghs", gs.stage_hunk, "Stage Hunk")
                map("n", "<leader>ghr", gs.reset_hunk, "Reset Hunk")
                map("v", "<leader>ghs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                    "Stage Hunk")
                map("v", "<leader>ghr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
                    "Reset Hunk")
                map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
                map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
                map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
                map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
                map("n", "<leader>ghi", gs.preview_hunk_inline, "Preview Hunk Inline")
                map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
                map("n", "<leader>ghd", gs.diffthis, "Diff This")
                map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")

                -- Toggle
                map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle Line Blame")
                map("n", "<leader>gtd", gs.toggle_deleted, "Toggle Deleted")
            end,
        },
    },
}
