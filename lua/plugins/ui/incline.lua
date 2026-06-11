-- Per-window floating filename (top-right). Fills the gap for
-- non-focused splits since lualine uses laststatus=3 (global).
return {
    "b0o/incline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
    event = "VeryLazy",
    config = function()
        local palette = require("config.palette")
        local p = palette.mocha()
        local damin_pink = palette.pink
        local devicons = require("nvim-web-devicons")
        local icon_cache, icon_cache_n = {}, 0
        local function icon_for(filename)
            local hit = icon_cache[filename]
            if hit then
                return hit[1], hit[2]
            end
            local i, c = devicons.get_icon_color(filename)
            if icon_cache_n >= 256 then -- bound the cache; distinct filenames are few
                icon_cache, icon_cache_n = {}, 0
            end
            icon_cache[filename] = { i, c }
            icon_cache_n = icon_cache_n + 1
            return i, c
        end

        -- Recompute the tabpage's zoomed state only when window topology changes.
        local zoomed_by_tab = {}
        local function tab_zoomed(tab)
            local hit = zoomed_by_tab[tab]
            if hit ~= nil then
                return hit
            end
            local z = #vim.api.nvim_tabpage_list_wins(tab) == 1
            zoomed_by_tab[tab] = z
            return z
        end
        vim.api.nvim_create_autocmd({ "WinNew", "WinClosed", "TabEnter", "TabNew" }, {
            group = vim.api.nvim_create_augroup("InclineZoomCache", { clear = true }),
            callback = function()
                zoomed_by_tab = {}
            end,
        })

        -- Cache diagnostic counts; vim.diagnostic.count walks the buffer cache each redraw.
        local ERROR, WARN = vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN
        local diag_by_buf = {}
        local function diag_counts(buf)
            local hit = diag_by_buf[buf]
            if hit then
                return hit[1], hit[2]
            end
            local diag = vim.diagnostic.count(buf)
            local errs, warns = diag[ERROR] or 0, diag[WARN] or 0
            diag_by_buf[buf] = { errs, warns }
            return errs, warns
        end
        local diag_cache_grp = vim.api.nvim_create_augroup("InclineDiagCache", { clear = true })
        vim.api.nvim_create_autocmd("DiagnosticChanged", {
            group = diag_cache_grp,
            callback = function(args)
                diag_by_buf[args.buf] = nil
            end,
        })
        -- Prune on wipe, else entries leak by bufnr.
        vim.api.nvim_create_autocmd("BufWipeout", {
            group = diag_cache_grp,
            callback = function(args)
                diag_by_buf[args.buf] = nil
            end,
        })

        -- Devicon colors can change with the theme.
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("InclineIconCache", { clear = true }),
            callback = function()
                icon_cache, icon_cache_n = {}, 0
            end,
        })

        -- Cache buffer name; nvim_buf_get_name allocates a string each redraw.
        local name_by_buf = {}
        local function buf_name(buf)
            local hit = name_by_buf[buf]
            if hit then
                return hit
            end
            local bufname = vim.api.nvim_buf_get_name(buf)
            name_by_buf[buf] = bufname
            return bufname
        end
        local name_cache_grp = vim.api.nvim_create_augroup("InclineNameCache", { clear = true })
        -- Invalidate on rename; prune on wipe, else entries leak by bufnr.
        vim.api.nvim_create_autocmd({ "BufFilePost", "BufWipeout" }, {
            group = name_cache_grp,
            callback = function(args)
                name_by_buf[args.buf] = nil
            end,
        })

        require("incline").setup({
            window = {
                padding = 0,
                margin = { horizontal = 0, vertical = 0 },
                placement = { horizontal = "right", vertical = "top" },
                zindex = 30,
            },
            hide = {
                cursorline = false,
                focused_win = false,
                only_win = "count_ignored",
            },
            -- Skip chrome buffers (they have their own labels).
            ignore = {
                buftypes = function(_, buftype)
                    return buftype ~= "" and buftype ~= "acwrite"
                end,
                filetypes = require("config.chrome_filetypes").panels,
                unlisted_buffers = false,
                wintypes = "special",
            },
            render = function(props)
                if not vim.api.nvim_buf_is_valid(props.buf) then
                    return ""
                end
                local bufname = buf_name(props.buf)
                -- Lua tail instead of fnamemodify(":t") — avoids a vimL call per render.
                local filename = bufname == "" and "[No Name]" or (bufname:match("[^/]+$") or bufname)
                local ft_icon, ft_color = icon_for(filename)
                local modified = vim.bo[props.buf].modified
                local readonly = vim.bo[props.buf].readonly
                -- ⌬ = "zoom": this window owns its tabpage alone.
                local tab = vim.api.nvim_win_get_tabpage(props.win)
                local zoomed = tab_zoomed(tab)

                local accent = props.focused and damin_pink or p.overlay1

                -- Per-window diagnostic count (lualine is global, can't show per-split).
                local errs, warns = diag_counts(props.buf)

                return {
                    zoomed and { "⌬ ", guifg = damin_pink } or "",
                    ft_icon and { ft_icon, " ", guifg = ft_color } or "",
                    {
                        filename,
                        gui = props.focused and "bold" or "NONE",
                        guifg = accent,
                    },
                    modified and { " ✿", guifg = damin_pink } or "",
                    readonly and { " ✗", guifg = p.red } or "",
                    errs > 0 and { " ✗" .. errs, guifg = p.red } or "",
                    warns > 0 and { " !" .. warns, guifg = p.yellow } or "",
                    guibg = "NONE",
                }
            end,
        })
    end,
}
