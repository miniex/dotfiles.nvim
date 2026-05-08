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

local SIDEBAR_FT = {
    ["neo-tree"] = true,
    ["neo-tree-popup"] = true,
}

local function is_main_area(win)
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
        return false
    end
    return not SIDEBAR_FT[vim.bo[buf].filetype]
end

local function toggle_terminal()
    if not is_main_area(0) then
        local cur = vim.api.nvim_get_current_win()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if win ~= cur and is_main_area(win) then
                if not any_term_visible() then
                    restore_win = cur
                end
                vim.api.nvim_set_current_win(win)
                break
            end
        end
    end
    -- Snacks caches `opts.win` at terminal creation, so a terminal first opened
    -- from neo-tree stays anchored there forever. Re-point every snacks
    -- terminal at the (now-focused) code window before each toggle.
    if Snacks.terminal.list then
        local target = vim.api.nvim_get_current_win()
        for _, t in ipairs(Snacks.terminal.list()) do
            if t.opts and t.opts.win then
                t.opts.win = target
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

-- Dashboard's chafa ANSI output fights with snacks.dim/indent overlays when
-- another window (e.g., neo-tree) takes focus, glitching the image. Disable
-- those features for the dashboard buffer.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "snacks_dashboard",
    group = vim.api.nvim_create_augroup("SnacksDashboardOverlay", { clear = true }),
    callback = function(args)
        vim.b[args.buf].snacks_dim = false
        vim.b[args.buf].snacks_indent = false
        vim.b[args.buf].snacks_scroll = false
    end,
})

-- When the last real file buffer is removed, drop the dashboard into the
-- main-area window instead of leaving an empty `[No Name]` buffer.
local function open_dashboard_if_empty(closing)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
            buf ~= closing
            and vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].buflisted
            and vim.bo[buf].buftype == ""
            and vim.api.nvim_buf_get_name(buf) ~= ""
        then
            return
        end
    end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b = vim.api.nvim_win_get_buf(win)
        if vim.bo[b].buftype ~= "terminal" and not SIDEBAR_FT[vim.bo[b].filetype] then
            vim.api.nvim_set_current_win(win)
            break
        end
    end
    Snacks.dashboard.open()
end

vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup("SnacksDashboardOnLastClose", { clear = true }),
    callback = function(args)
        local closing = args.buf
        vim.schedule(function()
            open_dashboard_if_empty(closing)
        end)
    end,
})

-- 5-step gradient (sky blue → light pink) for the NEOVIM header.
local header_gradient = { "#87CEEB", "#A5C8E1", "#C3C2D7", "#E1BCCC", "#FFB6C1" }
local function set_header_hl()
    for i, color in ipairs(header_gradient) do
        vim.api.nvim_set_hl(0, "DashHeader" .. i, { fg = color, bold = true })
    end
end
set_header_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("DashHeaderGradient", { clear = true }),
    callback = set_header_hl,
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
                keys = {
                    {
                        icon = " ",
                        key = "f",
                        desc = "Find",
                        action = ":lua require('fff').find_files()",
                        hidden = true,
                    },
                    {
                        icon = " ",
                        key = "g",
                        desc = "Grep",
                        action = ":lua Snacks.dashboard.pick('grep')",
                        hidden = true,
                    },
                    {
                        icon = " ",
                        key = "r",
                        desc = "Recent",
                        action = ":lua Snacks.dashboard.pick('recent')",
                        hidden = true,
                    },
                    {
                        icon = " ",
                        key = "c",
                        desc = "Config",
                        action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
                        hidden = true,
                    },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa", hidden = true },
                },
            },
            -- Responsive: when window height is tight, drop the NEOVIM header
            -- first, then the recent files. Image + menu + startup always stay.
            -- Re-evaluated on WinResized/VimResized via snacks's update().
            sections = function(self)
                local h = self:size().height
                local result = {
                    {
                        section = "terminal",
                        cmd = "cat " .. vim.fn.stdpath("config") .. "/assets/dashboard_sticker.ansi",
                        height = 24,
                        width = 60,
                        padding = 1,
                        align = "center",
                    },
                }

                if h >= 40 then
                    table.insert(result, {
                        text = { [[ _   _  _____   ___  __     __ ___  __  __ ]], hl = "DashHeader1" },
                        align = "center",
                        padding = 0,
                    })
                    table.insert(result, {
                        text = { [[| \ | || ____| / _ \ \ \   / /|_ _||  \/  |]], hl = "DashHeader2" },
                        align = "center",
                        padding = 0,
                    })
                    table.insert(result, {
                        text = { [[|  \| ||  _|  | | | | \ \ / /  | | | |\/| |]], hl = "DashHeader3" },
                        align = "center",
                        padding = 0,
                    })
                    table.insert(result, {
                        text = { [[| |\  || |___ | |_| |  \ V /   | | | |  | |]], hl = "DashHeader4" },
                        align = "center",
                        padding = 0,
                    })
                    table.insert(result, {
                        text = { [[|_| \_||_____| \___/    \_/   |___||_|  |_|]], hl = "DashHeader5" },
                        align = "center",
                        padding = 1,
                    })
                end

                -- keys section still emits keymaps (f/g/r/c/q stay bound) but
                -- items are hidden; show a compact icon strip instead.
                table.insert(result, { section = "keys", padding = 0 })
                table.insert(result, {
                    text = {
                        { "\u{F002}  ", hl = "Function" },
                        { "f", hl = "SnacksDashboardKey" },
                        { "      " },
                        { "\u{F00E}  ", hl = "String" },
                        { "g", hl = "SnacksDashboardKey" },
                        { "      " },
                        { "\u{F1DA}  ", hl = "Constant" },
                        { "r", hl = "SnacksDashboardKey" },
                        { "      " },
                        { "\u{F013}  ", hl = "Special" },
                        { "c", hl = "SnacksDashboardKey" },
                        { "      " },
                        { "\u{F011}  ", hl = "ErrorMsg" },
                        { "q", hl = "SnacksDashboardKey" },
                    },
                    align = "center",
                    padding = 1,
                })

                if h >= 34 then
                    table.insert(
                        result,
                        { icon = " ", title = "Recent Files", section = "recent_files", limit = 5, padding = 1 }
                    )
                end

                table.insert(result, { section = "startup" })
                return result
            end,
        },
        dim = { enabled = true },
        image = { enabled = vim.env.TERM == "xterm-kitty" or vim.env.KITTY_WINDOW_ID ~= nil },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000,
        },
        picker = {
            enabled = true,
            ui_select = true,
            win = {
                input = {
                    keys = {
                        ["<Esc>"] = { "close", mode = { "n", "i" } },
                    },
                },
            },
        },
        profiler = {
            -- Enable the module so Snacks.profiler.* APIs are available.
            -- Use `PROF=1 nvim` to capture startup; toggle at runtime via the
            -- keymaps below.
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
                height = 0.3,
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
            "<leader>fg",
            function()
                Snacks.picker.grep()
            end,
            desc = "Live Grep",
        },
        {
            "<leader>fr",
            function()
                Snacks.picker.recent()
            end,
            desc = "Recent Files",
        },
        {
            "<leader>fb",
            function()
                Snacks.picker.buffers()
            end,
            desc = "Buffers",
        },
        {
            "<leader>fh",
            function()
                Snacks.picker.help()
            end,
            desc = "Help Tags",
        },
        {
            "<leader>w",
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
            "<leader>pp",
            function()
                Snacks.profiler.toggle()
            end,
            desc = "Profiler Toggle",
        },
        {
            "<leader>ps",
            function()
                Snacks.profiler.scratch()
            end,
            desc = "Profiler Scratch Buffer",
        },
        {
            "<leader>pf",
            function()
                Snacks.profiler.pick()
            end,
            desc = "Profiler Pick",
        },
        {
            "<leader>ph",
            function()
                Snacks.profiler.highlights()
            end,
            desc = "Profiler Highlights",
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
