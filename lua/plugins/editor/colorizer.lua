return {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerReloadAllBuffers" },
    keys = {
        { "<leader>uC", "<cmd>ColorizerToggle<cr>", desc = "Toggle Colorizer" },
    },
    opts = {
        filetypes = {
            "*",
            "!lazy",
            -- color-heavy filetypes: full color syntaxes incl. 0xAARRGGBB and the
            -- 3/4-digit shorthand (valid CSS) that the global default turns off.
            css = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true, AARRGGBB = true, RGB = true, RGBA = true },
            scss = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true, AARRGGBB = true, RGB = true, RGBA = true },
            sass = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true, AARRGGBB = true, RGB = true, RGBA = true },
            less = { rgb_fn = true, hsl_fn = true, css = true, css_fn = true, AARRGGBB = true, RGB = true, RGBA = true },
            html = { names = false, AARRGGBB = true },
            xml = { names = false, AARRGGBB = true },
            -- code files: hex colors only, no names (avoid false positives on plain identifiers/numbers).
            lua = { names = false },
            toml = { names = false },
            json = { names = false },
        },
        user_default_options = {
            names = false,
            -- Only 6/8-digit hex. 3-digit (#RGB) and 4-digit (#RGBA) shorthand
            -- false-positives on issue/PR refs like #590 / #710 / #5901.
            -- css-family filetypes re-enable shorthand via the `css` preset.
            RGB = false,
            RGBA = false,
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
