local restore_win = nil

local function any_term_visible()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" then
            return true
        end
    end
    return false
end

local function toggle_terminal()
    if not any_term_visible() and vim.bo.filetype == "neo-tree" then
        restore_win = vim.api.nvim_get_current_win()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
            if ft ~= "neo-tree" then
                vim.api.nvim_set_current_win(win)
                break
            end
        end
    end
    Snacks.terminal.toggle()
end

local restore_group = vim.api.nvim_create_augroup("SnacksTerminalRestore", { clear = true })

local function do_restore()
    if not restore_win then
        return
    end
    local target = restore_win
    restore_win = nil
    vim.schedule(function()
        if vim.api.nvim_win_is_valid(target) then
            vim.api.nvim_set_current_win(target)
        end
    end)
end

vim.api.nvim_create_autocmd("TermClose", {
    group = restore_group,
    callback = do_restore,
})

vim.api.nvim_create_autocmd("WinClosed", {
    group = restore_group,
    callback = function(args)
        if not restore_win then
            return
        end
        local win = tonumber(args.match)
        if not win then
            return
        end
        local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
        if not ok then
            return
        end
        local bt_ok, bt = pcall(vim.api.nvim_get_option_value, "buftype", { buf = buf })
        if not bt_ok or bt ~= "terminal" then
            return
        end
        do_restore()
    end,
})

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        bufdelete = { enabled = true },
        dashboard = {
            enabled = true,
            preset = {
                header = table.concat({
                    [[        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗       ]],
                    [[        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║       ]],
                    [[        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║       ]],
                    [[        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║       ]],
                    [[        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║       ]],
                    [[        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝       ]],
                }, "\n"),
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                    { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
                    { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
                    {
                        icon = " ",
                        key = "c",
                        desc = "Config",
                        action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
                    },
                    { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
            },
            sections = {
                { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
                { icon = " ", title = "Recent Files", section = "recent_files", limit = 5, padding = 1 },
                { section = "startup" },
            },
        },
        dim = { enabled = true },
        image = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000,
        },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        terminal = {
            enabled = true,
            win = {
                relative = "win",
                position = "bottom",
                height = 0.45,
                wo = { winbar = "" },
                keys = {
                    term_close = { "<C-x>", "hide", mode = { "n", "t" }, desc = "Hide Terminal" },
                },
            },
        },
        words = { enabled = true },
    },
    keys = {
        {
            "<leader>bd",
            function()
                Snacks.bufdelete()
            end,
            desc = "Delete Buffer",
        },
        {
            "<leader>t",
            toggle_terminal,
            mode = { "n", "t" },
            desc = "Toggle Terminal",
        },
        {
            "<leader>un",
            function()
                Snacks.notifier.hide()
            end,
            desc = "Dismiss All Notifications",
        },
        {
            "<leader>cn",
            function()
                Snacks.notifier.show_history()
            end,
            desc = "Notification History",
        },
        {
            "]]",
            function()
                Snacks.words.jump(vim.v.count1)
            end,
            mode = { "n", "t" },
            desc = "Next Reference",
        },
        {
            "[[",
            function()
                Snacks.words.jump(-vim.v.count1)
            end,
            mode = { "n", "t" },
            desc = "Prev Reference",
        },
    },
}
