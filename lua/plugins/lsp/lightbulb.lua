-- VSCode-style code action indicator in the sign column.
-- damin tone: pink ❋ glyph, hooked to LspAttach.
return {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
        -- CursorHold only (no CursorHoldI): skip codeAction requests on insert idle.
        -- updatetime = -1 so lightbulb keeps the global 300ms (options.lua), not its own.
        autocmd = { enabled = true, updatetime = -1, events = { "CursorHold" } },
        sign = {
            enabled = true,
            text = "❋",
            hl = "LightBulbSign",
        },
        virtual_text = { enabled = false },
        float = { enabled = false },
        status_text = { enabled = false },
        number = { enabled = false },
        line = { enabled = false },
    },
    config = function(_, opts)
        require("nvim-lightbulb").setup(opts)
        local function set_hl()
            vim.api.nvim_set_hl(0, "LightBulbSign", { fg = require("config.palette").pink, bg = "NONE" })
        end
        set_hl()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("LightBulbDamin", { clear = true }),
            callback = set_hl,
        })
    end,
}
