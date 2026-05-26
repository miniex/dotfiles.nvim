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
    R = damin_pink,
    c = damin_blue,
    t = damin_blue,
}

local sign_ns = vim.api.nvim_create_namespace("ModicatorBloom")
local excluded_ft = {
    snacks_picker_input = true,
    snacks_picker_list = true,
    snacks_picker_preview = true,
    snacks_terminal = true,
    fff_input = true,
    fff_list = true,
    fff_preview = true,
    fzf = true,
    fzflua_backdrop = true,
}
local last_color
local last_buf, last_line
local function refresh_sign()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
        return
    end
    local line = vim.fn.line(".") - 1
    local color = mode_color[vim.fn.mode()] or damin_blue
    if color ~= last_color then
        vim.api.nvim_set_hl(0, "ModicatorBloomCurrent", { fg = color, bold = true })
        last_color = color
    end
    -- Skip rewrite when buf+line unchanged (horizontal motion).
    if buf == last_buf and line == last_line then
        return
    end
    if last_buf and vim.api.nvim_buf_is_valid(last_buf) then
        vim.api.nvim_buf_clear_namespace(last_buf, sign_ns, 0, -1)
    end
    pcall(vim.api.nvim_buf_set_extmark, buf, sign_ns, line, 0, {
        sign_text = "✿",
        sign_hl_group = "ModicatorBloomCurrent",
        priority = 100,
    })
    last_buf, last_line = buf, line
end

-- 16ms debounce so held j/k doesn't rewrite extmarks per frame.
local refresh_pending = false
local function schedule_refresh()
    if refresh_pending then
        return
    end
    -- Bail before arming the defer.
    if vim.bo.buftype ~= "" or excluded_ft[vim.bo.filetype] then
        return
    end
    refresh_pending = true
    vim.defer_fn(function()
        refresh_pending = false
        refresh_sign()
    end, 16)
end

return {
    "mawkler/modicator.nvim",
    event = "VeryLazy",
    init = function()
        -- Highlight only line-number column. Other requirements in options.lua.
        vim.o.cursorlineopt = "number"
    end,
    config = function(_, opts)
        require("modicator").setup(opts)
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged", "BufEnter" }, {
            group = vim.api.nvim_create_augroup("ModicatorBloomSign", { clear = true }),
            callback = schedule_refresh,
        })
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
