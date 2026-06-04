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
            "<leader>zw",
            function()
                require("fzf-lua").grep_cword()
            end,
            desc = "Grep word under cursor",
        },
        {
            "<leader>zw",
            function()
                require("fzf-lua").grep_visual()
            end,
            mode = "x",
            desc = "Grep visual selection",
        },
        {
            "<leader>zg",
            function()
                require("fzf-lua").git_status()
            end,
            desc = "Git Status",
        },
        {
            "<leader>zh",
            function()
                require("fzf-lua").git_stash()
            end,
            desc = "Git Stash",
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
        {
            "<leader>fS",
            function()
                local ls = require("luasnip")
                local ft = vim.bo.filetype
                local lookup, items = {}, {}
                local function collect(scope)
                    for _, snip in ipairs(ls.get_snippets(scope) or {}) do
                        local id = tostring(#items + 1)
                        lookup[id] = snip
                        local desc = snip.name or snip.dscr or ""
                        if type(desc) == "table" then
                            desc = table.concat(desc, " ")
                        end
                        table.insert(items, string.format("%-4s [%s] %s\t%s", id, scope, snip.trigger, desc))
                    end
                end
                collect(ft)
                if ft ~= "all" then
                    collect("all")
                end
                if #items == 0 then
                    vim.notify("No snippets for filetype: " .. ft, vim.log.levels.INFO)
                    return
                end
                require("fzf-lua").fzf_exec(items, {
                    prompt = "Snippets❯ ",
                    actions = {
                        ["default"] = function(selected)
                            local id = selected[1]:match("^(%S+)")
                            local snip = id and lookup[id]
                            if not snip then
                                return
                            end
                            vim.cmd("startinsert")
                            vim.schedule(function()
                                ls.snip_expand(snip)
                            end)
                        end,
                    },
                })
            end,
            desc = "Snippets (LuaSnip)",
        },
    },
    opts = {
        "default-title",
        winopts = {
            height = 0.85,
            width = 0.85,
            border = vim.g.flower_border,
            title = " ✿ fzf ✿ ",
            title_pos = "center",
            backdrop = 100,
            -- fzf-lua sets filetype under eventignore=all, so modal-geom's
            -- FileType aligner misses it. Use its own on_create hook instead.
            on_create = function()
                local win = vim.api.nvim_get_current_win()
                local cfg = vim.api.nvim_win_get_config(win)
                if cfg.relative == "" then
                    return
                end
                local rect = require("config.modal-geom").inner_rect()
                rect.relative = cfg.relative
                pcall(vim.api.nvim_win_set_config, win, rect)
            end,
            preview = {
                default = "bat",
                layout = "flex",
                border = vim.g.flower_border,
                title_pos = "center",
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
