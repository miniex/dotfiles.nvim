return {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerReloadAllBuffers" },
    keys = {
        { "<leader>uC", "<cmd>ColorizerToggle<cr>", desc = "Toggle Colorizer" },
    },
    opts = {
        filetypes = {
            "*",
            "!lazy",
            css = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true },
            html = { names = false },
            -- hex only for code files (avoid rgb()-shaped numeric false positives).
            lua = { names = false },
            toml = { names = false },
            json = { names = false },
        },
        user_default_options = {
            names = false,
            RRGGBBAA = true,
            AARRGGBB = true,
            rgb_fn = false,
            hsl_fn = false,
            css = false,
            css_fn = false,
            mode = "background",
            tailwind = false,
            virtualtext = "■",
            always_update = false,
        },
    },
}
