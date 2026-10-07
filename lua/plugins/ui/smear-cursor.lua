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
        },
    },
}
