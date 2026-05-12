-- Two-color identity, matching fish-theme-damin:
--   #98ABCC cool blue  → branch / cwd / mode-normal / strings & types accent
--   #E890B0 warm pink  → modified / heart bullet / mode-insert / WinSeparator
local damin_blue = "#98ABCC"
local damin_pink = "#E890B0"

return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = true,
                term_colors = true,
                no_italic = false,
                color_overrides = {
                    mocha = {
                        -- Collapse the cool-blue family onto the single damin blue.
                        blue = damin_blue,
                        sapphire = damin_blue,
                        sky = damin_blue,
                        teal = damin_blue,
                        -- Collapse the warm-pink family onto the single damin pink.
                        pink = damin_pink,
                        flamingo = damin_pink,
                        mauve = damin_pink,
                        rosewater = damin_pink,
                    },
                },
                custom_highlights = function(_)
                    return {
                        WinSeparator = { fg = damin_pink, bg = "NONE" },
                        VertSplit = { fg = damin_pink, bg = "NONE" },
                        FloatBorder = { fg = damin_pink, bg = "NONE" },
                    }
                end,
                integrations = {
                    aerial = true,
                    bufferline = true,
                    cmp = true,
                    fidget = true,
                    flash = true,
                    gitsigns = true,
                    grug_far = true,
                    harpoon = true,
                    indent_blankline = { enabled = true },
                    mason = true,
                    native_lsp = { enabled = true },
                    navic = { enabled = true, custom_bg = "NONE" },
                    neotree = true,
                    notify = true,
                    snacks = { enabled = true },
                    telescope = { enabled = false },
                    treesitter = true,
                    treesitter_context = true,
                    which_key = true,
                },
            })

            vim.cmd([[colorscheme catppuccin]])
        end,
    },
}
