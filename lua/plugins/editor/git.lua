return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(
                opts.ensure_installed,
                { "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes" }
            )
        end,
    },
    {
        "saghen/blink.cmp",
        optional = true,
        dependencies = { "Kaiser-Yang/blink-cmp-git" },
        opts = {
            sources = {
                per_filetype = {
                    gitcommit = { "git", inherit_defaults = true },
                },
                providers = {
                    git = {
                        module = "blink-cmp-git",
                        name = "Git",
                        opts = {},
                    },
                },
            },
        },
    },

    -- LazyGit: Floating window for the lazygit TUI
    {
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
            { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit Current File" },
            { "<leader>gF", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit Filter Current File" },
            { "<leader>gL", "<cmd>LazyGitFilter<cr>", desc = "LazyGit Filter" },
        },
        init = function()
            vim.g.lazygit_floating_window_winblend = 0
            vim.g.lazygit_floating_window_scaling_factor = 0.85
            vim.g.lazygit_floating_window_border_chars = vim.g.flower_border
            -- 0 = nvim_open_win path (respects flower chars). plenary popup
            -- misaligns the ✿ glyphs against lazygit's internal TUI grid.
            vim.g.lazygit_floating_window_use_plenary = 0

            -- lazygit.nvim doesn't expose a title option; inject one via FileType.
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "lazygit",
                group = vim.api.nvim_create_augroup("LazyGitTitle", { clear = true }),
                callback = function()
                    vim.schedule(function()
                        local win = vim.api.nvim_get_current_win()
                        pcall(vim.api.nvim_win_set_config, win, {
                            title = " ✿ lazygit ✿ ",
                            title_pos = "center",
                        })
                    end)
                end,
            })
            vim.g.lazygit_use_neovim_remote = 1
        end,
    },

    -- Fugitive: Git wrapper for Neovim
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G", "Gstatus", "Gblame", "Gpush", "Gpull", "Gdiff", "Glog" },
        keys = {
            { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
            { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git Blame" },
            { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git Diff" },
            { "<leader>gdv", "<cmd>Gvdiffsplit!<cr>", desc = "Git 3-way Diff (merge conflict)" },
            { "<leader>gl", "<cmd>Git log --oneline<cr>", desc = "Git Log" },
            { "<leader>gp", "<cmd>Git push<cr>", desc = "Git Push" },
            { "<leader>gP", "<cmd>Git pull<cr>", desc = "Git Pull" },
            { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git Commit" },
        },
    },

    -- git-conflict: Navigate and resolve merge conflict markers
    {
        "akinsho/git-conflict.nvim",
        version = "*",
        event = { "BufReadPre", "BufNewFile" },
        cmd = {
            "GitConflictChooseOurs",
            "GitConflictChooseTheirs",
            "GitConflictChooseBoth",
            "GitConflictChooseNone",
            "GitConflictNextConflict",
            "GitConflictPrevConflict",
            "GitConflictListQf",
        },
        keys = {
            { "<leader>gxq", "<cmd>GitConflictListQf<cr>", desc = "Conflicts to Quickfix" },
            -- ]X/[X: lowercase [x owned by treesitter-context.
            { "]X", "<cmd>GitConflictNextConflict<cr>", desc = "Next Git Conflict" },
            { "[X", "<cmd>GitConflictPrevConflict<cr>", desc = "Prev Git Conflict" },
        },
        opts = {
            default_mappings = true,
            default_commands = true,
            disable_diagnostics = false,
            list_opener = "copen",
            highlights = {
                incoming = "DiffAdd",
                current = "DiffText",
            },
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
                map("v", "<leader>ghs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Stage Hunk")
                map("v", "<leader>ghr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Reset Hunk")
                map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
                map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
                map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
                map("n", "<leader>ghi", gs.preview_hunk_inline, "Preview Hunk Inline")
                map("n", "<leader>ghb", function()
                    gs.blame_line({ full = true })
                end, "Blame Line")
                -- Full-file blame view; press `s`/`S` inside to open the commit.
                map("n", "<leader>ghc", gs.blame, "Blame File (commit nav)")
                map("n", "<leader>ghd", gs.diffthis, "Diff This")
                map("n", "<leader>ghD", function()
                    gs.diffthis("~")
                end, "Diff This ~")
                map("n", "<leader>ghq", function()
                    gs.setqflist("attached")
                end, "Hunks to QF (attached)")

                -- Toggle
                map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle Line Blame")
                map("n", "<leader>gtd", gs.toggle_deleted, "Toggle Deleted")
            end,
        },
    },
}
