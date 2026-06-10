-- Right-edge scrollbar with diagnostic/git marks. Animated heart + faded handle.
local chrome = require("config.chrome_filetypes")
local pal = require("config.palette")
local excluded_ft = chrome.set(chrome.pickers, chrome.panels)
excluded_ft.prompt = true

-- excluded_filetypes gates the plugin's render, not these per-keystroke callbacks.
local function is_excluded(buf)
    local ft = buf and vim.bo[buf] and vim.bo[buf].filetype or vim.bo.filetype
    if excluded_ft[ft] then
        return true
    end
    local bt = buf and vim.bo[buf] and vim.bo[buf].buftype or vim.bo.buftype
    return bt == "terminal" or bt == "prompt"
end

return {
    "petertriho/nvim-scrollbar",
    event = "BufReadPost",
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
        require("scrollbar").setup({
            throttle_ms = 16, -- 60fps cap for smooth cursor animation
            handle = {
                text = "▐",
                color = pal.blue,
                blend = 50,
            },
            marks = {
                -- Diagnostic/Search/Misc handlers index text[1] — wrap in array.
                Cursor = { text = "♥", color = pal.pink },
                Search = { text = { "★" }, color = pal.pink },
                Error = { text = { "●" }, color = pal.pink },
                Warn = { text = { "◆" }, color = pal.pink },
                Info = { text = { "•" }, color = pal.blue },
                Hint = { text = { "·" }, color = pal.blue },
                Misc = { text = { "•" }, color = pal.blue },
                GitAdd = { text = "▐", color = pal.git_add }, -- mint
                GitChange = { text = "▐", color = pal.pink }, -- pink
                GitDelete = { text = "▁", color = pal.git_delete }, -- rose
            },
            excluded_filetypes = vim.tbl_keys(excluded_ft),
            handlers = {
                cursor = false, -- custom animated cursor below
                diagnostic = true,
                gitsigns = true,
                handle = true,
                search = false,
                ale = false,
            },
        })

        local function hex_to_rgb(hex)
            hex = hex:gsub("#", "")
            return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
        end

        local function lerp_color(c1, c2, t)
            local r1, g1, b1 = hex_to_rgb(c1)
            local r2, g2, b2 = hex_to_rgb(c2)
            return string.format(
                "#%02X%02X%02X",
                math.floor(r1 + (r2 - r1) * t + 0.5),
                math.floor(g1 + (g2 - g1) * t + 0.5),
                math.floor(b1 + (b2 - b1) * t + 0.5)
            )
        end

        local function stop(timer)
            if timer and not timer:is_closing() then
                timer:stop()
                timer:close()
            end
            return nil
        end

        -- Cursor color is driven by the heartbeat timer; everything else stays solid.
        local mark_colors = {
            Search = pal.pink,
            Error = pal.pink,
            Warn = pal.pink,
            Info = pal.blue,
            Hint = pal.blue,
            Misc = pal.blue,
            GitAdd = pal.git_add,
            GitChange = pal.pink,
            GitDelete = pal.git_delete,
        }

        local function apply_mark_hl()
            for name, color in pairs(mark_colors) do
                vim.api.nvim_set_hl(0, "Scrollbar" .. name, { fg = color })
                vim.api.nvim_set_hl(0, "Scrollbar" .. name .. "Handle", { fg = color })
            end
        end

        -- Handle: fade between active/idle.
        local active_color = pal.blue
        local idle_color = "#5F6A82"
        local idle_delay_ms = 700
        local fade_duration_ms = 500
        local fade_steps = 12

        local current_color = idle_color
        local fade_timer
        local idle_timer

        local function set_handle(color)
            current_color = color
            vim.api.nvim_set_hl(0, "ScrollbarHandle", { fg = color })
        end

        local function start_fade(from, to, duration_ms)
            fade_timer = stop(fade_timer)
            local step_ms = math.max(1, math.floor(duration_ms / fade_steps))
            local i = 0
            local my_timer = vim.uv.new_timer()
            fade_timer = my_timer
            my_timer:start(
                step_ms,
                step_ms,
                vim.schedule_wrap(function()
                    if fade_timer ~= my_timer then
                        return
                    end
                    i = i + 1
                    set_handle(lerp_color(from, to, i / fade_steps))
                    if i >= fade_steps then
                        fade_timer = stop(fade_timer)
                    end
                end)
            )
        end

        -- Heart: lub-dub pulse. Baseline pink keeps it visible mid-slide.
        local heart_dim = pal.pink
        local heart_bright = "#FFD4DE"
        local heart_period_ms = 1100
        local pulse_frame_ms = 150 -- ~6.7Hz; smooth enough at the 1.1s period.

        local function heartbeat_curve(t)
            local function bump(center, width)
                local x = (t - center) / width
                return math.exp(-x * x)
            end
            return math.min(1, bump(0.15, 0.06) + 0.7 * bump(0.40, 0.07))
        end

        -- Plugin reload would stack pulse writers on ScrollbarCursor; stop the prior timer first.
        if _G._scrollbar_pulse_timer then
            pcall(function()
                _G._scrollbar_pulse_timer:stop()
                _G._scrollbar_pulse_timer:close()
            end)
            _G._scrollbar_pulse_timer = nil
        end

        local pulse_start = vim.uv.hrtime() / 1e6
        local pulse_timer
        local last_pulse_color
        local function pulse_tick()
            local now = vim.uv.hrtime() / 1e6
            local t = ((now - pulse_start) % heart_period_ms) / heart_period_ms
            local c = lerp_color(heart_dim, heart_bright, heartbeat_curve(t))
            -- Heartbeat lingers near heart_dim; skip the redundant set_hl pair.
            if c == last_pulse_color then
                return
            end
            last_pulse_color = c
            vim.api.nvim_set_hl(0, "ScrollbarCursor", { fg = c })
            vim.api.nvim_set_hl(0, "ScrollbarCursorHandle", { fg = c })
        end
        local function start_pulse()
            if pulse_timer then
                return
            end
            pulse_start = vim.uv.hrtime() / 1e6 -- reset phase
            last_pulse_color = nil
            pulse_timer = vim.uv.new_timer()
            _G._scrollbar_pulse_timer = pulse_timer
            pulse_timer:start(0, pulse_frame_ms, vim.schedule_wrap(pulse_tick))
        end
        local function stop_pulse()
            if pulse_timer then
                pulse_timer:stop()
                pulse_timer:close()
                pulse_timer = nil
                _G._scrollbar_pulse_timer = nil
            end
        end
        start_pulse()

        -- Cursor mark: lerps line position so the heart slides instead of teleporting.
        local scrollbar = require("scrollbar")
        local sb_utils = require("scrollbar.utils")
        local sb_config = require("scrollbar.config")

        local move_duration_ms = 220
        local move_frame_ms = 33 -- ~30fps; halves full-render count per cursor move
        local move_timer
        local displayed_lines = {}

        local function render_cursor(bufnr, line)
            if not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end
            local cfg = sb_config.get()
            local marks = sb_utils.get_scrollbar_marks(bufnr)
            marks.cursor = {
                {
                    line = line,
                    text = cfg.marks["Cursor"].text,
                    type = "Cursor",
                    level = 1,
                },
            }
            sb_utils.set_scrollbar_marks(bufnr, marks)
            scrollbar.render()
        end

        local function snap_cursor(bufnr, line)
            move_timer = stop(move_timer)
            displayed_lines[bufnr] = line
            render_cursor(bufnr, line)
        end

        local snap_jump_threshold = 20
        local big_buf_lines = 5000 -- above this, snap the mark (skip the 30fps render loop)
        local function animate_cursor(bufnr, target)
            local from = displayed_lines[bufnr]
            if from == nil or from == target then
                snap_cursor(bufnr, target)
                return
            end
            if vim.api.nvim_buf_line_count(bufnr) > big_buf_lines then
                snap_cursor(bufnr, target)
                return
            end
            -- Held j/k or large jump: snap instead of arming a new timer each press.
            if math.abs(target - from) > snap_jump_threshold then
                snap_cursor(bufnr, target)
                return
            end
            move_timer = stop(move_timer)
            local steps = math.max(1, math.floor(move_duration_ms / move_frame_ms))
            local i = 0
            local my_timer = vim.uv.new_timer()
            move_timer = my_timer
            my_timer:start(
                move_frame_ms,
                move_frame_ms,
                vim.schedule_wrap(function()
                    if move_timer ~= my_timer then
                        return
                    end
                    i = i + 1
                    local t = i / steps
                    local eased = 1 - (1 - t) * (1 - t) * (1 - t)
                    local cur = math.floor(from + (target - from) * eased + 0.5)
                    local last = displayed_lines[bufnr]
                    displayed_lines[bufnr] = cur
                    -- Skip re-render when the interpolated line is unchanged; always render the last frame.
                    if cur ~= last or i >= steps then
                        render_cursor(bufnr, cur)
                    end
                    if i >= steps then
                        displayed_lines[bufnr] = target
                        move_timer = stop(move_timer)
                    end
                end)
            )
        end

        -- 50ms throttle: avoid stop/new uv timer per keystroke.
        local last_idle_arm_ms = 0
        local function poke_handle()
            fade_timer = stop(fade_timer)
            if current_color ~= active_color then
                set_handle(active_color)
            end
            local now = vim.uv.hrtime() / 1e6
            if now - last_idle_arm_ms < 50 then
                return
            end
            last_idle_arm_ms = now
            idle_timer = stop(idle_timer)
            local my_timer = vim.uv.new_timer()
            idle_timer = my_timer
            my_timer:start(
                idle_delay_ms,
                0,
                vim.schedule_wrap(function()
                    if idle_timer ~= my_timer then
                        return
                    end
                    idle_timer = stop(idle_timer)
                    start_fade(active_color, idle_color, fade_duration_ms)
                end)
            )
        end

        set_handle(idle_color)
        apply_mark_hl()

        local scrollbar_group = vim.api.nvim_create_augroup("ScrollbarDaminEvents", { clear = true })

        vim.api.nvim_create_autocmd("CursorMoved", {
            group = scrollbar_group,
            callback = function(event)
                if is_excluded(event.buf) then
                    return
                end
                poke_handle()
                animate_cursor(event.buf, vim.fn.line(".") - 1)
            end,
        })

        -- Insert mode fires per keystroke; skip animation to keep typing snappy, and
        -- only re-render when the line actually changes (same-line typing = no-op).
        vim.api.nvim_create_autocmd("CursorMovedI", {
            group = scrollbar_group,
            callback = function(event)
                if is_excluded(event.buf) then
                    return
                end
                poke_handle()
                local line = vim.fn.line(".") - 1
                if displayed_lines[event.buf] ~= line then
                    snap_cursor(event.buf, line)
                end
            end,
        })

        vim.api.nvim_create_autocmd("WinScrolled", {
            group = scrollbar_group,
            callback = function()
                if is_excluded(vim.api.nvim_get_current_buf()) then
                    return
                end
                poke_handle()
            end,
        })

        -- Snap on context switch — no animation continuity across buffers/windows.
        vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
            group = scrollbar_group,
            callback = function(event)
                if is_excluded(event.buf) then
                    return
                end
                if vim.api.nvim_buf_is_valid(event.buf) then
                    snap_cursor(event.buf, vim.fn.line(".") - 1)
                end
            end,
        })

        vim.api.nvim_create_autocmd("BufWipeout", {
            group = scrollbar_group,
            callback = function(event)
                displayed_lines[event.buf] = nil
            end,
        })

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = scrollbar_group,
            callback = function()
                set_handle(current_color)
                apply_mark_hl()
                last_pulse_color = nil
            end,
        })

        -- Pause pulse when unfocused or on chrome buffers (terminals/pickers/panels)
        -- so it isn't repainting highlights where no scrollbar is even shown.
        local function should_pulse()
            return not is_excluded()
        end
        local function maybe_start_pulse()
            if should_pulse() then
                start_pulse()
            else
                stop_pulse()
            end
        end
        vim.api.nvim_create_autocmd("FocusLost", {
            group = scrollbar_group,
            callback = stop_pulse,
        })
        vim.api.nvim_create_autocmd("FocusGained", {
            group = scrollbar_group,
            callback = maybe_start_pulse,
        })
        vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
            group = scrollbar_group,
            callback = maybe_start_pulse,
        })
        -- The heart isn't watched while typing; pause the pulse in insert mode.
        vim.api.nvim_create_autocmd("InsertEnter", {
            group = scrollbar_group,
            callback = stop_pulse,
        })
        vim.api.nvim_create_autocmd("InsertLeave", {
            group = scrollbar_group,
            callback = maybe_start_pulse,
        })
        vim.api.nvim_create_autocmd("VimLeavePre", {
            group = scrollbar_group,
            callback = function()
                stop_pulse()
                stop(fade_timer)
                stop(idle_timer)
                stop(move_timer)
            end,
        })

        vim.schedule(function()
            snap_cursor(vim.api.nvim_get_current_buf(), vim.fn.line(".") - 1)
        end)
    end,
}
