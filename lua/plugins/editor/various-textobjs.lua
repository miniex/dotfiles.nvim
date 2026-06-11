-- Extra text objects (indentation / value / key) atop mini.ai + treesitter.
-- Defaults off; ai/ii are taken (conditional), so indentation lives on iI/aI.
return {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    opts = { keymaps = { useDefaults = false } },
    config = function(_, opts)
        require("various-textobjs").setup(opts)
        local vt = require("various-textobjs")
        local function xo(lhs, fn, desc)
            vim.keymap.set({ "x", "o" }, lhs, fn, { desc = desc })
        end
        xo("iI", function()
            vt.indentation("inner", "inner")
        end, "Indentation (inner)")
        xo("aI", function()
            vt.indentation("outer", "inner")
        end, "Indentation (outer)")
        xo("iv", function()
            vt.value("inner")
        end, "Value (inner)")
        xo("av", function()
            vt.value("outer")
        end, "Value (outer)")
        xo("ik", function()
            vt.key("inner")
        end, "Key (inner)")
        xo("ak", function()
            vt.key("outer")
        end, "Key (outer)")
        -- subword segment — `s` is flash and `aS` is a ts statement, so it's on ie/ae.
        xo("ie", function()
            vt.subword("inner")
        end, "Subword (inner)")
        xo("ae", function()
            vt.subword("outer")
        end, "Subword (outer)")
        -- url has no inner/outer; both keys grab the whole URL.
        xo("iu", function()
            vt.url()
        end, "URL")
        xo("au", function()
            vt.url()
        end, "URL")
    end,
}
