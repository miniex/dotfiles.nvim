return {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
        -- Blocky "pixel" trail: quadrant blocks only, 4 flat shade steps, short tail.
        use_diagonal_blocks = false,
        max_shade_no_matrix = 1.0,
        matrix_pixel_threshold = 0.5,
        color_levels = 4,
        gradient_exponent = 0,
        -- Snappy, no overshoot; tail capped so it reads as a streak, not a smear.
        stiffness = 0.7,
        trailing_stiffness = 0.45,
        trailing_exponent = 2,
        damping = 0.95,
        max_length = 10,
        stiffness_insert_mode = 0.6,
        trailing_stiffness_insert_mode = 0.6,
        damping_insert_mode = 0.95,
        distance_stop_animating = 0.3,
        -- Only real jumps animate: j/k and short h/l stay instant.
        smear_between_neighbor_lines = false,
        min_horizontal_distance_smear = 3,
        hide_target_hack = false,
        smear_terminal_mode = false,
    },
    config = function(_, opts)
        local smear = require("smear_cursor")
        smear.setup(opts)

        -- enabled lives on the module (__newindex toggles listen/unlisten);
        -- smear_terminal_mode is a config key.
        local sc = require("smear_cursor.config")
        local grp = vim.api.nvim_create_augroup("SmearCursorAutocmds", { clear = true })

        -- smear hides the real cursor (`a:SmearCursorHideable`, blend=100) while it
        -- animates and unhides only when the animation ends. Switching it off mid-flight
        -- strands that state, so the cursor stays invisible in the float we just entered.
        -- jump() unhides and resets it; deferred past the 80ms float-open window below.
        local function restore_real_cursor()
            if smear.enabled then
                return
            end
            local ok, row, col = pcall(require("smear_cursor.screen").get_screen_cursor_position)
            if ok and row then
                require("smear_cursor.animation").jump(row, col)
            end
        end

        -- Each smear.enabled write re-runs unlisten/listen + a deferred jump_cursor
        -- even when unchanged; guard so repeated chrome-buffer passes don't churn.
        local function set_smear(v)
            if smear.enabled ~= v then
                smear.enabled = v
            end
            if not v then
                vim.defer_fn(restore_real_cursor, 100)
            end
        end

        -- Sticky-off: outlives the 80ms float-open defer below; spring would otherwise
        -- fire per CursorMovedI in snacks_picker_input.
        local chrome = require("config.chrome_filetypes")
        local sticky_disabled_ft = chrome.set(chrome.pickers)
        local function should_stay_disabled(buf)
            buf = buf or 0
            if sticky_disabled_ft[vim.bo[buf].filetype] then
                return true
            end
            local bt = vim.bo[buf].buftype
            return bt == "terminal" or bt == "prompt"
        end

        -- One WinEnter pass for terminal pulse + float-open skip (was two autocmds).
        local term_gen, float_gen = 0, 0
        vim.api.nvim_create_autocmd("WinEnter", {
            group = grp,
            callback = function()
                -- Pulse smear on terminal enter only; persistent mode jitters keystrokes.
                if vim.bo.buftype == "terminal" then
                    sc.smear_terminal_mode = true
                    term_gen = term_gen + 1
                    local mine = term_gen
                    vim.defer_fn(function()
                        if mine == term_gen then
                            sc.smear_terminal_mode = false
                        end
                    end, 300)
                end

                -- Skip smear on float open: the (1,1) landing + the plugin's own
                -- cursor placement fire back-to-back; 80ms swallows both jumps.
                if should_stay_disabled(0) then
                    set_smear(false)
                    float_gen = float_gen + 1
                    return
                end
                if vim.api.nvim_win_get_config(0).relative == "" then
                    return
                end
                set_smear(false)
                float_gen = float_gen + 1
                local mine = float_gen
                vim.defer_fn(function()
                    if mine == float_gen and not should_stay_disabled(0) then
                        set_smear(true)
                    end
                end, 80)
            end,
        })

        -- ft is set after WinEnter for snacks_picker_input / fzf; recheck here.
        vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
            group = grp,
            callback = function(event)
                if should_stay_disabled(event.buf) then
                    set_smear(false)
                    float_gen = float_gen + 1
                end
            end,
        })

        -- Restore smear when leaving a sticky-disabled window for a normal one.
        vim.api.nvim_create_autocmd("WinLeave", {
            group = grp,
            callback = function()
                if should_stay_disabled(0) then
                    vim.schedule(function()
                        if not should_stay_disabled(0) then
                            set_smear(true)
                        end
                    end)
                end
            end,
        })
    end,
}
