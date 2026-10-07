return {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
        -- Smooth: full shade gradient, diagonal blocks, ~144fps frames.
        use_diagonal_blocks = true,
        color_levels = 16,
        gradient_exponent = 1.0,
        time_interval = 7,
        -- Soft spring, no overshoot; long tail fades out.
        stiffness = 0.6,
        trailing_stiffness = 0.4,
        trailing_exponent = 3,
        damping = 0.9,
        stiffness_insert_mode = 0.5,
        trailing_stiffness_insert_mode = 0.5,
        damping_insert_mode = 0.9,
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
        },
    },
}
