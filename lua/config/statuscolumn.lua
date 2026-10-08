-- Hand-rolled statuscolumn: fold | 2 signs | number | git. gitsigns sit right of the
-- number instead of sharing (and reordering) the sign column with diagnostics / bloom.
-- No cache: per-line extmark lookups are a few µs, and a cache would show the
-- bloom sign a frame late.
local M = {}

local SIGNS = 2 -- like signcolumn=yes:2: bloom ✿ can't hide a diagnostic / breakpoint

local function cell(text, hl)
    text = vim.fn.strcharpart(text or "", 0, 2)
    text = text .. (" "):rep(2 - vim.api.nvim_strwidth(text))
    return hl and ("%#" .. hl .. "#" .. text .. "%*") or text
end

local function by_priority(a, b)
    return (a.priority or 0) > (b.priority or 0)
end

function M.render()
    local win = vim.g.statusline_winid
    local wo = vim.wo[win]
    local number = wo.number or wo.relativenumber
    local signs = wo.signcolumn ~= "no"
    if not (number or signs) then
        return "%C"
    end
    local num = number and "%=%l " or ""
    -- Wrapped continuation rows: keep the gutter width, no number / signs.
    if vim.v.virtnum ~= 0 then
        return "%C" .. (signs and (" "):rep(SIGNS * 2) or "") .. (number and "%= " or "") .. (signs and "  " or "")
    end
    if not signs then
        return "%C" .. num
    end
    local buf = vim.api.nvim_win_get_buf(win)
    local row = vim.v.lnum - 1
    local list, git = {}, nil
    for _, m in
        ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, { row, 0 }, { row, -1 }, { type = "sign", details = true }))
    do
        local d = m[4]
        if d.sign_text then
            if (d.sign_hl_group or ""):find("^GitSigns") then
                if not git or by_priority(d, git) then
                    git = d
                end
            else
                list[#list + 1] = d
            end
        end
    end
    table.sort(list, by_priority)
    local out = { "%C" }
    for i = 1, SIGNS do
        out[#out + 1] = cell(list[i] and list[i].sign_text, list[i] and list[i].sign_hl_group)
    end
    out[#out + 1] = num
    out[#out + 1] = cell(git and git.sign_text, git and git.sign_hl_group)
    return table.concat(out)
end

vim.o.statuscolumn = "%!v:lua.require'config.statuscolumn'.render()"

return M
