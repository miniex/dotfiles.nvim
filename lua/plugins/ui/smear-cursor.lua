return {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
        -- Fast spring + no-trail. Matching stiffness/trailing = no smear stretch.
        stiffness = 0.5,
        trailing_stiffness = 0.5,
        stiffness_insert_mode = 0.4,
        trailing_stiffness_insert_mode = 0.4,
        damping = 0.85,
        damping_insert_mode = 0.85,
        distance_stop_animating = 0.3,
        matrix_pixel_threshold = 0.5,
        hide_target_hack = false,
        smear_terminal_mode = false,
    },
    config = function(_, opts)
        require("smear_cursor").setup(opts)

        local sc = require("smear_cursor.config")
        local grp = vim.api.nvim_create_augroup("SmearCursorAutocmds", { clear = true })

        -- Pulse smear on terminal enter only; persistent mode jitters keystrokes.
        local term_gen = 0
        vim.api.nvim_create_autocmd("WinEnter", {
            group = grp,
            callback = function()
                if vim.bo.buftype ~= "terminal" then
                    return
                end
                sc.smear_terminal_mode = true
                term_gen = term_gen + 1
                local mine = term_gen
                vim.defer_fn(function()
                    if mine == term_gen then
                        sc.smear_terminal_mode = false
                    end
                end, 300)
            end,
        })

        -- Skip smear on float open: the (1,1) landing + the plugin's own
        -- cursor placement fire back-to-back; 80ms swallows both jumps.
        local float_gen = 0
        vim.api.nvim_create_autocmd("WinEnter", {
            group = grp,
            callback = function()
                if vim.api.nvim_win_get_config(0).relative == "" then
                    return
                end
                sc.enabled = false
                float_gen = float_gen + 1
                local mine = float_gen
                vim.defer_fn(function()
                    if mine == float_gen then
                        sc.enabled = true
                    end
                end, 80)
            end,
        })
    end,
}
