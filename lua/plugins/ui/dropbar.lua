return {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "nvim-telescope/telescope-fzf-native.nvim",
        optional = true,
    },
    keys = {
        {
            "<leader>uw",
            function()
                require("dropbar.api").pick()
            end,
            desc = "Dropbar: pick segment",
        },
        {
            "[w",
            function()
                require("dropbar.api").goto_context_start()
            end,
            desc = "Dropbar: jump to context start",
        },
        {
            "]w",
            function()
                require("dropbar.api").select_next_context()
            end,
            desc = "Dropbar: next context",
        },
    },
    opts = {
        bar = {
            -- Keep the dashboard / neo-tree / terminals clean.
            enable = function(buf, win, _)
                if vim.fn.win_gettype(win) ~= "" then
                    return false
                end
                local bt = vim.bo[buf].buftype
                if bt ~= "" and bt ~= "acwrite" then
                    return false
                end
                local ft = vim.bo[buf].filetype
                if ft == "snacks_dashboard" or ft == "neo-tree" or ft == "Trouble" or ft == "dap-repl" then
                    return false
                end
                if vim.api.nvim_buf_get_name(buf) == "" then
                    return false
                end
                return true
            end,
            padding = { left = 1, right = 1 },
        },
        icons = {
            ui = {
                bar = {
                    separator = "  ",
                    extends = "…",
                },
            },
        },
        menu = {
            -- Match the rounded borders used by completion / signature / hover
            -- so the picker visually belongs to the same UI family.
            win_configs = {
                border = "rounded",
                col = function(menu)
                    return menu.prev_menu and menu.prev_menu._win_configs.width + 1 or 0
                end,
            },
            preview = true,
            quick_navigation = true,
            keymaps = {
                ["q"] = function()
                    local menu = require("dropbar.api").get_current_dropbar_menu()
                    if menu then
                        menu:close()
                    end
                end,
                ["<Esc>"] = function()
                    local menu = require("dropbar.api").get_current_dropbar_menu()
                    if menu then
                        menu:close()
                    end
                end,
                ["h"] = "<C-w>q",
                ["l"] = function()
                    local menu = require("dropbar.api").get_current_dropbar_menu()
                    if not menu then
                        return
                    end
                    local row = vim.api.nvim_win_get_cursor(menu.win)[1]
                    local component = menu.entries[row]:first_clickable()
                    if component then
                        menu:click_on(component, nil, 1, "l")
                    end
                end,
            },
        },
        sources = {
            path = {
                relative_to = function(_, win)
                    if not vim.api.nvim_win_is_valid(win) then
                        return vim.fn.getcwd()
                    end
                    return vim.fn.getcwd(vim.api.nvim_win_get_number(win))
                end,
            },
        },
    },
    config = function(_, opts)
        require("dropbar").setup(opts)
    end,
}
