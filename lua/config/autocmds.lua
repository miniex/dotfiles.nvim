-- Skip non-file buffers (stat noise) and large files (reload cost).
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = vim.api.nvim_create_augroup("auto-checktime", { clear = true }),
    callback = function(args)
        -- TermClose can fire after the buffer is wiped (snacks term toggle) → vim.bo[buf] throws E11.
        if not vim.api.nvim_buf_is_valid(args.buf) then
            return
        end
        if vim.bo[args.buf].buftype ~= "" then
            return
        end
        -- Stat for size once per buffer, not on every BufEnter.
        local skip = vim.b[args.buf].checktime_skip_large
        if skip == nil then
            local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(args.buf))
            skip = size > 10 * 1024 * 1024
            -- Don't cache for a not-yet-written buffer (size -1); re-check once it exists.
            if size >= 0 then
                vim.b[args.buf].checktime_skip_large = skip
            end
        end
        if skip then
            return
        end
        vim.cmd("checktime")
    end,
})

-- Hide ~ at EOB (covers plugins that override winhighlight/fillchars).
local function hide_eob()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    local bg = normal and normal.bg
    if bg then
        vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = bg })
    end
end
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("hide-eob", { clear = true }),
    callback = hide_eob,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("yank-flash", { clear = true }),
    callback = function()
        if vim.fn.reg_recording() ~= "" then
            return
        end
        (vim.hl or vim.highlight).on_yank({ timeout = 150 })
    end,
})

-- Equalize splits on terminal resize (covers tmux pane / font-size changes).
vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("auto-equalize-splits", { clear = true }),
    callback = function()
        vim.cmd("wincmd =")
    end,
})

-- TextYankPost → system clipboard. Deferred: first yank can't beat the schedule.
vim.schedule(function()
    local clip_cmd
    if vim.fn.executable("wl-copy") == 1 then
        clip_cmd = { "wl-copy" }
    elseif vim.fn.executable("xclip") == 1 then
        clip_cmd = { "xclip", "-selection", "clipboard" }
    elseif vim.fn.executable("pbcopy") == 1 then
        clip_cmd = { "pbcopy" }
    elseif vim.fn.executable("/mnt/c/Windows/System32/clip.exe") == 1 then
        clip_cmd = { "/mnt/c/Windows/System32/clip.exe" }
    end
    local copy
    if clip_cmd then
        copy = function(content)
            vim.system(clip_cmd, { stdin = content })
        end
    else
        -- No clipboard binary (e.g. SSH): emit OSC52 so the terminal copies.
        local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
        if ok then
            copy = function(content)
                osc52.copy("+")(vim.split(content, "\n"))
            end
        end
    end
    if not copy then
        return
    end
    -- Yank-only + 50ms debounce so macros don't fork dozens of clipboard processes.
    local pending_content, pending_timer
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("YankToClipboard", { clear = true }),
        callback = function()
            if vim.v.event.operator ~= "y" then
                return
            end
            pending_content = table.concat(vim.v.event.regcontents, "\n")
            -- table.concat drops the line-wise trailing newline.
            if vim.v.event.regtype == "V" then
                pending_content = pending_content .. "\n"
            end
            if pending_timer and not pending_timer:is_closing() then
                pending_timer:stop()
                pending_timer:close()
            end
            -- Local handle so the callback closes its own timer, not a newer
            -- one that replaced it on a fast re-yank.
            local timer = vim.uv.new_timer()
            pending_timer = timer
            timer:start(
                50,
                0,
                vim.schedule_wrap(function()
                    if not timer:is_closing() then
                        timer:close()
                    end
                    -- A newer yank may have superseded this timer; only the current one copies.
                    if pending_timer ~= timer then
                        return
                    end
                    pending_timer = nil
                    copy(pending_content)
                end)
            )
        end,
    })
end)

-- mkdir parent dir on save (so :e new/path/file works).
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("auto-mkdir", { clear = true }),
    callback = function(args)
        if args.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        pcall(vim.fn.mkdir, vim.fn.fnamemodify(args.file, ":p:h"), "p")
    end,
})

-- Restore last cursor position via the `"` mark (persisted by shada).
-- Guard the win check: persistence re-fires BufReadPost via nvim_buf_call.
vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("restore-cursor", { clear = true }),
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft == "gitcommit" or ft == "gitrebase" then
            return
        end
        if vim.api.nvim_win_get_buf(0) ~= args.buf then
            return
        end
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local last = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= last then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Macro recording on/off → toast so it's never a surprise.
local macro_toast = vim.api.nvim_create_augroup("macro-toast", { clear = true })
vim.api.nvim_create_autocmd("RecordingEnter", {
    group = macro_toast,
    callback = function()
        vim.notify("recording @" .. vim.fn.reg_recording(), vim.log.levels.INFO, { title = "macro" })
    end,
})
vim.api.nvim_create_autocmd("RecordingLeave", {
    group = macro_toast,
    callback = function()
        vim.notify("saved @" .. vim.v.event.regname, vim.log.levels.INFO, { title = "macro" })
    end,
})

-- Snacks terminal: start in insert so `<leader>t` is type-ready immediately.
-- Schedule so the dashboard sticker's terminal buf gets its `snacks_dashboard`
-- ft before the check — otherwise insert mode leaks into the dashboard.
vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup("snacks-term-insert", { clear = true }),
    callback = function(args)
        if vim.bo[args.buf].buftype ~= "terminal" then
            return
        end
        vim.schedule(function()
            if
                vim.api.nvim_buf_is_valid(args.buf)
                and vim.api.nvim_get_current_buf() == args.buf
                and vim.bo[args.buf].filetype ~= "snacks_dashboard"
            then
                vim.cmd.startinsert()
            end
        end)
    end,
})

-- ui2's pager doesn't surface `:messages` for us — render the history in a modal instead.
vim.api.nvim_create_user_command("Messages", function()
    local out = vim.fn.execute("messages")
    local lines = vim.split(out, "\n", { plain = true })
    while #lines > 0 and lines[1] == "" do
        table.remove(lines, 1)
    end
    if #lines == 0 then
        vim.notify("no messages", vim.log.levels.INFO)
        return
    end
    local win = require("config.modal-geom").scratch(lines, { filetype = "messages", title = "messages" })
    vim.api.nvim_win_set_cursor(win, { #lines, 0 })
end, { desc = "Show :messages in a centered modal" })
vim.cmd([[cnoreabbrev <expr> messages getcmdtype() == ':' && getcmdline() == 'messages' ? 'Messages' : 'messages']])

-- Treesitter attach. Pre-plugin so startup-loaded files get highlighted.
-- get_lang() handles ft↔parser mismatches (e.g. typescriptreact → tsx).
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("ts-attach", { clear = true }),
    callback = function(args)
        if vim.treesitter.highlighter.active[args.buf] then
            return
        end
        -- Big-file guard: skip TS on huge/minified buffers (per-keystroke re-parse
        -- stalls). snacks.bigfile degrades >2 MiB; this catches the 1-2 MiB rest.
        local name = vim.api.nvim_buf_get_name(args.buf)
        if name ~= "" and vim.fn.getfsize(name) > 1 * 1024 * 1024 then -- 1 MiB
            return
        end
        local first = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1]
        if first and #first > 2000 then
            return
        end
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang then
            return
        end
        if not pcall(vim.treesitter.start, args.buf) then
            return
        end
        -- Defer indentexpr to override default ftplugin indent (idempotent).
        vim.schedule(function()
            local expr = "v:lua.require'nvim-treesitter'.indentexpr()"
            if
                package.loaded["nvim-treesitter"]
                and vim.api.nvim_buf_is_valid(args.buf)
                and vim.bo[args.buf].indentexpr ~= expr
            then
                vim.bo[args.buf].indentexpr = expr
            end
        end)
    end,
})

-- Past 8 MiB, ask before opening: view in less (default) / edit / cancel.
-- Neovim reads the file once before any autocmd can stop it, so this gates the
-- editing, not the read; <leader>L (pager.lua) is the only true no-read path.
local BIG_FILE_LIMIT = 8 * 1024 * 1024 -- 8 MiB

-- snacks.bufdelete handles the sole-buffer case (startup `nvim hugefile`);
-- fall back to a forced wipe if snacks isn't loaded.
local function big_file_close(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    -- Drop it from the arglist too, else the saved session reopens it every
    -- launch (mksession always stores the arglist, even after the buffer's gone).
    local target = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p")
    for _, arg in ipairs(vim.fn.argv()) do
        if vim.fn.fnamemodify(arg, ":p") == target then
            pcall(vim.cmd, "argdelete " .. vim.fn.fnameescape(arg))
            break
        end
    end
    local ok = pcall(function()
        require("snacks").bufdelete(buf)
    end)
    if not ok and vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
end

-- NUL byte in the first KB → binary (the git/grep heuristic). less only mangles
-- binary and exits non-zero on it, so we drop the "view" option for those.
local function is_binary(file)
    local uv = vim.uv or vim.loop
    local fd = uv.fs_open(file, "r", 438)
    if not fd then
        return false
    end
    local data = uv.fs_read(fd, 1024, 0)
    uv.fs_close(fd)
    return type(data) == "string" and data:find("\0", 1, true) ~= nil
end

vim.api.nvim_create_autocmd("BufReadPre", {
    group = vim.api.nvim_create_augroup("big-file-guard", { clear = true }),
    callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then
            return
        end
        local size = vim.fn.getfsize(args.file)
        if size < BIG_FILE_LIMIT then
            return
        end
        local name = vim.fn.fnamemodify(args.file, ":t")
        local mib = string.format("%.1f MiB", size / 1024 / 1024)
        local file, buf = args.file, args.buf

        -- Binary: less errors / shows garbage, so no pager option.
        if is_binary(file) then
            if
                vim.fn.confirm(("%s is %s (binary)."):format(name, mib), "&Edit anyway\n&Cancel", 2, "Question") == 1
            then
                return
            end
            vim.schedule(function()
                big_file_close(buf)
            end)
            return
        end

        local choice =
            vim.fn.confirm(("%s is %s."):format(name, mib), "&View in less\n&Edit anyway\n&Cancel", 1, "Question")
        if choice == 2 then
            return -- edit anyway
        end
        -- Defer: deleting during BufReadPre errors (E201) + breaks other Read handlers.
        vim.schedule(function()
            if choice ~= 3 then
                require("config.pager").view(file)
            end
            big_file_close(buf)
        end)
    end,
})

-- Registers format-width's colorcolumn FileType autocmd.
require("config.format-width")
