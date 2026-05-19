-- damin 2-color: blue (#98ABCC) cool, pink (#E890B0) warm.
local damin_blue = "#98ABCC"
local damin_pink = "#E890B0"
-- Git accents — kept in sync with scrollbar marks.
local git_add = "#A8DBB6"
local git_change = damin_pink
local git_delete = "#D8788C"

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
                        BufferLineOffset = { fg = damin_pink, bg = "NONE", bold = true },

                        GitSignsAdd = { fg = git_add, bg = "NONE" },
                        GitSignsChange = { fg = git_change, bg = "NONE" },
                        GitSignsDelete = { fg = git_delete, bg = "NONE" },
                        GitSignsTopdelete = { fg = git_delete, bg = "NONE" },
                        GitSignsChangedelete = { fg = git_change, bg = "NONE" },
                        GitSignsUntracked = { fg = git_add, bg = "NONE" },
                        GitSignsAddNr = { fg = git_add, bg = "NONE" },
                        GitSignsChangeNr = { fg = git_change, bg = "NONE" },
                        GitSignsDeleteNr = { fg = git_delete, bg = "NONE" },
                        GitSignsAddLn = { fg = git_add, bg = "NONE" },
                        GitSignsChangeLn = { fg = git_change, bg = "NONE" },
                        DiagnosticSignError = { fg = damin_pink, bg = "NONE" },
                        DiagnosticSignWarn = { fg = damin_pink, bg = "NONE" },
                        DiagnosticSignInfo = { fg = damin_blue, bg = "NONE" },
                        DiagnosticSignHint = { fg = damin_blue, bg = "NONE" },
                        DiagnosticSignOk = { fg = damin_blue, bg = "NONE" },
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
