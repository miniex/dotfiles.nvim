return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
        {
            "<leader>z",
            function()
                require("fzf-lua").builtin()
            end,
            desc = "Fzf Builtin",
        },
        {
            "<leader>z'",
            function()
                require("fzf-lua").resume()
            end,
            desc = "Fzf Resume",
        },
        {
            "<leader>zg",
            function()
                require("fzf-lua").git_status()
            end,
            desc = "Git Status",
        },
        {
            "<leader>zc",
            function()
                require("fzf-lua").git_bcommits()
            end,
            desc = "Git Commits (Buffer)",
        },
        {
            "<leader>zC",
            function()
                require("fzf-lua").git_commits()
            end,
            desc = "Git Commits (Project)",
        },
        {
            "<leader>zb",
            function()
                require("fzf-lua").git_branches()
            end,
            desc = "Git Branches",
        },
        {
            "<leader>zs",
            function()
                require("fzf-lua").lsp_document_symbols()
            end,
            desc = "Document Symbols",
        },
        {
            "<leader>zS",
            function()
                require("fzf-lua").lsp_live_workspace_symbols()
            end,
            desc = "Workspace Symbols",
        },
        {
            "<leader>zd",
            function()
                require("fzf-lua").diagnostics_document()
            end,
            desc = "Diagnostics (Buffer)",
        },
        {
            "<leader>zD",
            function()
                require("fzf-lua").diagnostics_workspace()
            end,
            desc = "Diagnostics (Workspace)",
        },
        {
            "<leader>zl",
            function()
                require("fzf-lua").blines()
            end,
            desc = "Buffer Lines",
        },
        {
            "<leader>zk",
            function()
                require("fzf-lua").keymaps()
            end,
            desc = "Keymaps",
        },
        {
            "<leader>zm",
            function()
                require("fzf-lua").marks()
            end,
            desc = "Marks",
        },
        {
            "<leader>zr",
            function()
                require("fzf-lua").registers()
            end,
            desc = "Registers",
        },
        {
            "<leader>z:",
            function()
                require("fzf-lua").command_history()
            end,
            desc = "Command History",
        },
        {
            "<leader>z/",
            function()
                require("fzf-lua").search_history()
            end,
            desc = "Search History",
        },
    },
    opts = {
        "default-title",
        winopts = {
            height = 0.85,
            width = 0.85,
            border = "rounded",
            preview = {
                default = "bat",
                layout = "flex",
            },
        },
        keymap = {
            builtin = {
                ["<C-/>"] = "toggle-help",
                ["<C-d>"] = "preview-page-down",
                ["<C-u>"] = "preview-page-up",
            },
            fzf = {
                ["ctrl-q"] = "select-all+accept",
                ["ctrl-d"] = "preview-page-down",
                ["ctrl-u"] = "preview-page-up",
            },
        },
    },
}
