-- Focus the gitsigns popup so the cursor lands inside. Scheduled because
-- `preview_hunk` is sync-ish; for the async `blame_line`, pass this as its callback.
local function focus_gitsigns(id)
    vim.schedule(function()
        local ok, gpopup = pcall(require, "gitsigns.popup")
        if ok then
            gpopup.focus_open(id)
        end
    end)
end

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
                    -- Explicit list (no inherit_defaults): git source + path/buffer, no
                    -- LSP/snippets. Owned here since blink per_filetype lists replace, not merge.
                    gitcommit = { "git", "path", "buffer" },
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

    -- Fugitive: Git wrapper for Neovim
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G" },
        keys = {
            { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
            { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git Blame" },
            { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git Diff" },
            { "<leader>gD", "<cmd>Gvdiffsplit!<cr>", desc = "Git 3-way Diff (merge conflict)" },
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
        -- event-loaded (conflicts auto-highlight on open); default_commands registers the commands.
        event = { "BufReadPre", "BufNewFile" },
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
        config = function(_, opts)
            require("gitsigns").setup(opts)
            local function sync_preview_geom()
                local rect = require("config.modal-geom").inner_rect()
                rect.border = vim.g.flower_border
                rect.style = "minimal"
                rect.relative = "editor"
                require("gitsigns.config").config.preview_config = rect
            end
            sync_preview_geom()
            vim.api.nvim_create_autocmd("VimResized", {
                group = vim.api.nvim_create_augroup("GitsignsPreviewGeom", { clear = true }),
                callback = sync_preview_geom,
            })
        end,
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol",
                delay = 300,
            },
            current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
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

                -- Navigation (auto-preview on jump, wrap at ends)
                map("n", "]h", function()
                    gs.nav_hunk("next", { preview = true, wrap = true })
                end, "Next Hunk")
                map("n", "[h", function()
                    gs.nav_hunk("prev", { preview = true, wrap = true })
                end, "Prev Hunk")

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
                map("n", "<leader>ghp", function()
                    gs.preview_hunk()
                    focus_gitsigns("hunk")
                end, "Preview Hunk")
                -- Inline (virtual-line) diff; no float to focus.
                map("n", "<leader>ghi", gs.preview_hunk_inline, "Preview Hunk Inline")
                map("n", "<leader>ghb", function()
                    gs.blame_line({ full = true }, function()
                        focus_gitsigns("blame")
                    end)
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
                map("n", "<leader>gtw", gs.toggle_word_diff, "Toggle Word Diff")

                -- Hunk textobject: d ih / v ah.
                map({ "o", "x" }, "ih", gs.select_hunk, "Inner Hunk")
                map({ "o", "x" }, "ah", gs.select_hunk, "Around Hunk")
            end,
        },
    },
}
