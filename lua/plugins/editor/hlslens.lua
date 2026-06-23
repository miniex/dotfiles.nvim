local pal = require("config.palette")

-- Search lens: inline position at the nearest match + the scrollbar's `★` marks.
return {
    "kevinhwang91/nvim-hlslens",
    -- Loaded via nvim-scrollbar's dependencies so its search handler finds hlslens.
    lazy = true,
    opts = { nearest_only = true },
    config = function(_, opts)
        require("hlslens").setup(opts)

        local function lens_hl()
            vim.api.nvim_set_hl(0, "HlSearchLensNear", { fg = pal.pink, bold = true })
            vim.api.nvim_set_hl(0, "HlSearchLens", { fg = pal.bufferline_dim })
        end
        lens_hl()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("HlslensDamin", { clear = true }),
            callback = lens_hl,
        })

        -- Keep the config's zvzz centering (keymaps.lua) while wrapping with hlslens.
        local o = { silent = true }
        local tail = "zvzz<Cmd>lua require('hlslens').start()<CR>"
        vim.keymap.set("n", "n", "<Cmd>execute('normal! ' . v:count1 . 'n')<CR>" .. tail, o)
        vim.keymap.set("n", "N", "<Cmd>execute('normal! ' . v:count1 . 'N')<CR>" .. tail, o)
        for _, k in ipairs({ "*", "#", "g*", "g#" }) do
            vim.keymap.set("n", k, k .. tail, o)
        end
    end,
}
