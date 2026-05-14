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
            -- color-heavy filetypes: enable full color syntaxes including 0xAARRGGBB.
            css = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true, AARRGGBB = true },
            scss = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true, AARRGGBB = true },
            sass = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true, AARRGGBB = true },
            less = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true, AARRGGBB = true },
            html = { names = false, AARRGGBB = true },
            xml = { names = false, AARRGGBB = true },
            -- code files: hex colors only, no names (avoid false positives on plain identifiers/numbers).
            lua = { names = false },
            toml = { names = false },
            json = { names = false },
        },
        user_default_options = {
            names = false,
            RRGGBBAA = true,
            AARRGGBB = false,
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
