-- Hand-rolled statuscolumn: sign | number | git. gitsigns sit right of the number
-- instead of sharing (and reordering) the sign column with diagnostics / bloom.
-- No cache: per-line extmark lookups are a few µs, and a cache would show the
-- bloom sign a frame late.
local M = {}

local function cell(text, hl)
    text = text or ""
    text = vim.fn.strcharpart(text .. "  ", 0, 2)
    return hl and ("%#" .. hl .. "#" .. text .. "%*") or text
end

function M.render()
    local win = vim.g.statusline_winid
    if not (vim.wo[win].number or vim.wo[win].relativenumber) then
        return ""
    end
    -- Wrapped continuation rows: keep the gutter width, no number / signs.
    if vim.v.virtnum ~= 0 then
        return "  %=  "
    end
    local buf = vim.api.nvim_win_get_buf(win)
    local row = vim.v.lnum - 1
    local sign, git
    for _, m in
        ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, { row, 0 }, { row, -1 }, { type = "sign", details = true }))
    do
        local d = m[4]
        if d.sign_text then
            local prio = d.priority or 0
            if (d.sign_hl_group or ""):find("^GitSigns") then
                if not git or prio > (git.priority or 0) then
                    git = d
                end
            elseif not sign or prio > (sign.priority or 0) then
                sign = d
            end
        end
    end
    return cell(sign and sign.sign_text, sign and sign.sign_hl_group)
        .. "%=%l "
        .. cell(git and git.sign_text, git and git.sign_hl_group)
end

vim.o.statuscolumn = "%!v:lua.require'config.statuscolumn'.render()"

return M
