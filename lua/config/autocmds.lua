-- Skip non-file buffers; checktime would stat them on every BufEnter.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("auto-checktime", { clear = true }),
    callback = function(args)
        if vim.bo[args.buf].buftype == "" then
            vim.cmd("checktime")
        end
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
hide_eob()

-- TextYankPost → system clipboard. First available backend wins (Wayland / X11 / macOS / WSL2).
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
if clip_cmd then
    vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("YankToClipboard", { clear = true }),
        callback = function()
            local content = table.concat(vim.v.event.regcontents, "\n")
            vim.system(clip_cmd, { stdin = content })
        end,
    })
end

-- mkdir parent dir on save (so :e new/path/file works).
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("auto-mkdir", { clear = true }),
    callback = function(args)
        if args.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        vim.fn.mkdir(vim.fn.fnamemodify(args.file, ":p:h"), "p")
    end,
})

-- Restore last cursor position via the `"` mark (persisted by shada).
vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("restore-cursor", { clear = true }),
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft == "gitcommit" or ft == "gitrebase" then
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
vim.api.nvim_create_autocmd("RecordingEnter", {
    group = vim.api.nvim_create_augroup("macro-toast", { clear = true }),
    callback = function()
        vim.notify("recording @" .. vim.fn.reg_recording(), vim.log.levels.INFO, { title = "macro" })
    end,
})
vim.api.nvim_create_autocmd("RecordingLeave", {
    group = "macro-toast",
    callback = function()
        vim.notify("saved @" .. vim.v.event.regname, vim.log.levels.INFO, { title = "macro" })
    end,
})

-- Snacks terminal: start in insert so `<leader>t` is type-ready immediately.
vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup("snacks-term-insert", { clear = true }),
    callback = function(args)
        if vim.bo[args.buf].buftype == "terminal" then
            vim.cmd.startinsert()
        end
    end,
})

-- Treesitter attach. Pre-plugin so startup-loaded files get highlighted.
-- get_lang() handles ft↔parser mismatches (e.g. typescriptreact → tsx).
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("ts-attach", { clear = true }),
    callback = function(args)
        if vim.treesitter.highlighter.active[args.buf] then
            return
        end
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang then
            return
        end
        if not pcall(vim.treesitter.start, args.buf) then
            return
        end
        -- Defer indentexpr to override default ftplugin indent.
        vim.schedule(function()
            if package.loaded["nvim-treesitter"] and vim.api.nvim_buf_is_valid(args.buf) then
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end)
    end,
})
