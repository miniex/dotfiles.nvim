-- ✿ echo: line-number column accent + mode-aware sign in front.
local damin_blue = "#98ABCC"
local damin_pink = "#E890B0"

local mode_color = {
    n = damin_blue,
    i = damin_pink,
    v = damin_pink,
    V = damin_pink,
    ["\22"] = damin_pink,
    s = damin_pink,
    S = damin_pink,
    ["\19"] = damin_pink,
    R = "#f38ba8",
    c = "#9399b2",
    t = damin_blue,
}

local sign_ns = vim.api.nvim_create_namespace("ModicatorBloom")
local function refresh_sign()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype ~= "" then
        return
    end
    vim.api.nvim_buf_clear_namespace(buf, sign_ns, 0, -1)
    local line = vim.fn.line(".") - 1
    local color = mode_color[vim.fn.mode()] or damin_blue
    local hl = "ModicatorBloomCurrent"
    vim.api.nvim_set_hl(0, hl, { fg = color, bold = true })
    pcall(vim.api.nvim_buf_set_extmark, buf, sign_ns, line, 0, {
        sign_text = "✿",
        sign_hl_group = hl,
        priority = 100,
    })
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("ModicatorBloomSign", { clear = true }),
    callback = function()
        vim.schedule(refresh_sign)
    end,
})

return {
    "mawkler/modicator.nvim",
    event = "VeryLazy",
    init = function()
        -- Highlight only line-number column. Other requirements in options.lua.
        vim.o.cursorlineopt = "number"
    end,
    opts = {
        show_warnings = false,
        highlights = {
            defaults = { bold = true },
        },
        integration = {
            lualine = { enabled = true },
        },
    },
}
