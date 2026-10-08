return {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
        -- Smooth motion, solid tail: one color level, so nothing blends toward the
        -- (transparent) background and shows as a dark box. ~144fps frames.
        use_diagonal_blocks = true,
        -- Draw upper / right partial blocks directly (kitty renders the Legacy
        -- Computing glyphs itself). Without it they're inverted lower / left blocks
        -- whose fg is the bg fallback: dark slivers on a transparent terminal.
        legacy_computing_symbols_support = true,
        color_levels = 1,
        gradient_exponent = 0,
        time_interval = 7,
        -- Head lands almost at once (no lag behind the real cursor); only the tail eases.
        stiffness = 0.9,
        trailing_stiffness = 0.5,
        trailing_exponent = 3,
        damping = 0.95,
        stiffness_insert_mode = 0.9,
        trailing_stiffness_insert_mode = 0.6,
        damping_insert_mode = 0.95,
        distance_stop_animating = 0.1,
        -- Every move animates, including j/k and single-column h/l.
        smear_between_neighbor_lines = true,
        min_horizontal_distance_smear = 0,
        hide_target_hack = false,
        smear_terminal_mode = false,
        -- No smear across windows: float opens (pickers, hovers) would streak from (1,1).
        smear_between_buffers = false,
        -- Picker prompts/lists: cursor jumps per keystroke.
        filetypes_disabled = {
            "snacks_picker_input",
            "snacks_picker_list",
            "snacks_picker_preview",
            "snacks_terminal",
            "fff_input",
            "fff_list",
            "fff_preview",
            "fzf",
            "fzflua_backdrop",
            "bigfile",
        },
    },
    config = function(_, opts)
        local smear = require("smear_cursor")
        smear.setup(opts)
        -- Every frame is a full redraw (decoration providers, treesitter on_start);
        -- pause in huge buffers. Only undoes its own pause, not :SmearCursorToggle.
        local paused = false
        local function check(buf)
            local big = vim.api.nvim_buf_line_count(buf) > 10000
            if big and smear.enabled then
                smear.enabled, paused = false, true
            elseif not big and paused then
                smear.enabled, paused = true, false
            end
        end
        vim.api.nvim_create_autocmd("BufEnter", {
            group = vim.api.nvim_create_augroup("smear-big-buffer", { clear = true }),
            callback = function(args)
                check(args.buf)
            end,
        })
        check(vim.api.nvim_get_current_buf())
    end,
}
