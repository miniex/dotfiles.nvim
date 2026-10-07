-- Reload file buffers changed on disk, per-buffer so the size guard can skip large ones
-- (a bare `:checktime` reloads every buffer regardless of size).
local function checktime_buf(buf)
    if not vim.api.nvim_buf_is_loaded(buf) then
        return
    end
    if vim.bo[buf].buftype ~= "" then
        return
    end
    -- Stat for size once per buffer, not on every event.
    local skip = vim.b[buf].checktime_skip_large
    if skip == nil then
        local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))
        skip = size > 10 * 1024 * 1024
        -- Don't cache for a not-yet-written buffer (size -1); re-check once it exists.
        if size >= 0 then
            vim.b[buf].checktime_skip_large = skip
        end
    end
    if not skip then
        vim.cmd(buf .. "checktime")
    end
end

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = vim.api.nvim_create_augroup("auto-checktime", { clear = true }),
    callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            checktime_buf(buf)
        end
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("yank-flash", { clear = true }),
    callback = function()
        if vim.fn.reg_recording() ~= "" then
            return
        end
        vim.hl.on_yank({ timeout = 150 })
    end,
})

-- Equalize splits on terminal resize (covers tmux pane / font-size changes).
vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("auto-equalize-splits", { clear = true }),
    callback = function()
        vim.cmd("wincmd =")
    end,
})

-- Yanks (operator `y` only) also go to the system clipboard through nvim's provider
-- (wl-copy / xclip / pbcopy / clip.exe, OSC52 over SSH). Debounced so a macro full
-- of yanks spawns one copy, not dozens.
local yank_timer = vim.uv.new_timer()
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankToClipboard", { clear = true }),
    callback = function()
        -- Explicit "+y / "*y already went through the provider.
        if vim.v.event.operator ~= "y" or vim.v.event.regname == "+" or vim.v.event.regname == "*" then
            return
        end
        local contents, regtype = vim.v.event.regcontents, vim.v.event.regtype
        yank_timer:start(
            50,
            0,
            vim.schedule_wrap(function()
                pcall(vim.fn.setreg, "+", contents, regtype)
            end)
        )
    end,
})

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
            if pcall(vim.api.nvim_win_set_cursor, 0, mark) then
                -- Open folds + center, matching jump keymaps.
                pcall(vim.cmd, "normal! zvzz")
            end
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
        -- Only langs with an indents query; without one TS indent returns 0.
        if #vim.treesitter.query.get_files(lang, "indents") == 0 then
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

-- Drop `o` from formatoptions so o/O don't continue comment leaders (ftplugins set it).
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("formatoptions-no-o", { clear = true }),
    callback = function()
        vim.opt_local.formatoptions:remove("o")
    end,
})

-- Spell check (camelCase-aware via spelloptions) on prose filetypes only.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("spell-prose", { clear = true }),
    pattern = { "gitcommit", "markdown", "text" },
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en_us"
    end,
})

-- Clear the shada-restored jumplist at startup so <C-o> stays session-local.
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("session-local-jumps", { clear = true }),
    callback = function()
        vim.cmd("clearjumps")
    end,
})

-- `nvim <dir>`: globals chdir'd + argdelete'd; drop the leftover directory buffer so
-- it lands on the dashboard / restored session. Runs before persistence's autoload.
if vim.g.dir_launch then
    vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("dir-launch-clean", { clear = true }),
        once = true,
        callback = function()
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
                local name = vim.api.nvim_buf_get_name(b)
                if name ~= "" and vim.fn.isdirectory(name) == 1 then
                    pcall(vim.api.nvim_buf_delete, b, { force = true })
                end
            end
        end,
    })
end

-- gq/gw reflow width: formatter defaults; a project's .editorconfig max_line_length
-- wins (stock editorconfig runs after FileType).
local TEXTWIDTH = { c = 80, cpp = 80, elixir = 98, lua = 120, ocaml = 80, python = 88, rust = 100, sql = 80, toml = 80 }
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("textwidth", { clear = true }),
    pattern = vim.tbl_keys(TEXTWIDTH),
    callback = function(args)
        vim.bo[args.buf].textwidth = TEXTWIDTH[args.match]
    end,
})
