-- ✿ bloom: mode-colored sign on the current line. The sign was always custom;
-- modicator's line-number recolor needs cursorline (never set) so it was dropped.
local pal = require("config.palette")
local damin_blue = pal.blue
local damin_pink = pal.pink

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

local sign_ns = vim.api.nvim_create_namespace("CursorBloom")
local chrome = require("config.chrome_filetypes")
local excluded_ft = chrome.set(chrome.pickers, chrome.panels)
local last_color
local last_buf, last_line
local last_id, last_id_buf
local function refresh_sign()
    local buf = vim.api.nvim_get_current_buf()
    -- Re-check here (not just in schedule_refresh): the buffer can change in the 16ms window.
    if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" or excluded_ft[vim.bo[buf].filetype] then
        return
    end
    local line = vim.fn.line(".") - 1
    local color = mode_color[vim.fn.mode()] or damin_blue
    if color ~= last_color then
        vim.api.nvim_set_hl(0, "CursorBloomCurrent", { fg = color, bold = true })
        last_color = color
    end
    -- Skip rewrite when buf+line unchanged (horizontal motion).
    if buf == last_buf and line == last_line then
        return
    end
    -- Delete just the prior mark by id instead of clearing the whole namespace.
    if last_id and last_id_buf and vim.api.nvim_buf_is_valid(last_id_buf) then
        pcall(vim.api.nvim_buf_del_extmark, last_id_buf, sign_ns, last_id)
    end
    local ok, id = pcall(vim.api.nvim_buf_set_extmark, buf, sign_ns, line, 0, {
        sign_text = "✿",
        sign_hl_group = "CursorBloomCurrent",
        priority = 100,
    })
    last_id, last_id_buf = ok and id or nil, ok and buf or nil
    last_buf, last_line = buf, line
end

-- 16ms debounce so held j/k doesn't rewrite extmarks per frame. One reused
-- timer instead of a fresh vim.defer_fn closure per cursor move.
local refresh_pending = false
local refresh_timer
local function schedule_refresh()
    if refresh_pending then
        return
    end
    if vim.bo.buftype ~= "" or excluded_ft[vim.bo.filetype] then
        return
    end
    refresh_pending = true
    refresh_timer = refresh_timer or (vim.uv or vim.loop).new_timer()
    refresh_timer:start(
        16,
        0,
        vim.schedule_wrap(function()
            refresh_pending = false
            pcall(refresh_sign)
        end)
    )
end

local bloom_group = vim.api.nvim_create_augroup("CursorBloomSign", { clear = true })
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged", "BufEnter" }, {
    group = bloom_group,
    callback = schedule_refresh,
})
-- Reset trackers on wipe, else a reused bufnr on the same line skips the sign.
vim.api.nvim_create_autocmd("BufWipeout", {
    group = bloom_group,
    callback = function(args)
        if args.buf == last_buf then
            last_buf, last_line = nil, nil
        end
        if args.buf == last_id_buf then
            last_id, last_id_buf = nil, nil
        end
    end,
})
