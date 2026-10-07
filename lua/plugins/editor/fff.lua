return {
    "dmtrKovalenko/fff",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    keys = {
        {
            "<leader>ff",
            function()
                require("fff").find_files()
            end,
            desc = "Find Files (fff)",
        },
        {
            "<leader>fF",
            function()
                require("fff").find_files_in_dir(vim.fn.expand("%:p:h"))
            end,
            desc = "Find Files in current directory (fff)",
        },
    },
    opts = {
        prompt = "  ",
        title = "✿ files ✿",
        -- 0.85 × 0.85, input top, preview right 50% — matches snacks.picker.
        layout = {
            width = 0.85,
            height = 0.85,
            prompt_position = "top",
            preview_position = "right",
            preview_size = 0.5,
            -- { border chars, T-junctions ├ ┤ ┬ ┴ ┼ }
            border = { vim.g.flower_border, { "✿", "✿", "✿", "✿", "✿" } },
        },
        hl = { title = "FloatTitle" },
    },
}
