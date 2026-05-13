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

        -- Pulse smear on terminal enter only; persistent mode jitters keystrokes.
        local sc = require("smear_cursor.config")
        local gen = 0
        vim.api.nvim_create_autocmd("WinEnter", {
            group = vim.api.nvim_create_augroup("SmearTerminalEnterPulse", { clear = true }),
            callback = function()
                if vim.bo.buftype ~= "terminal" then
                    return
                end
                sc.smear_terminal_mode = true
                gen = gen + 1
                local mine = gen
                vim.defer_fn(function()
                    if mine == gen then
                        sc.smear_terminal_mode = false
                    end
                end, 300)
            end,
        })
    end,
}
