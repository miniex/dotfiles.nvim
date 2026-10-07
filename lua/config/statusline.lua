-- Hand-rolled global statusline (replaces lualine). Plain text on transparent bg:
--  NOR  main  lua/config/options.lua [+]  E1 W2      ⠋ lua_ls  lua_ls  +3 ~1 -0  [2/9]  42:7 31%
local pal = require("config.palette")

local MODES = {
    n = { "NOR", "N" },
    no = { "OPR", "V" },
    i = { "INS", "I" },
    ic = { "INS", "I" },
    v = { "VIS", "V" },
    V = { "V-L", "V" },
    ["\22"] = { "V-B", "V" },
    s = { "SEL", "V" },
    S = { "S-L", "V" },
    ["\19"] = { "S-B", "V" },
    R = { "REP", "R" },
    Rv = { "REP", "R" },
    c = { "CMD", "C" },
    t = { "TRM", "C" },
}

local function set_hl()
    local p = pal.mocha()
    local hl = function(name, spec)
        spec.bg = "NONE"
        vim.api.nvim_set_hl(0, name, spec)
    end
    hl("StatusLine", { fg = p.overlay1 })
    hl("StatusLineNC", { fg = p.overlay0 })
    hl("StlModeN", { fg = pal.blue, bold = true })
    hl("StlModeI", { fg = pal.pink, bold = true })
    hl("StlModeV", { fg = pal.pink, bold = true })
    hl("StlModeR", { fg = p.red, bold = true })
    hl("StlModeC", { fg = p.overlay2, bold = true })
    hl("StlBlue", { fg = pal.blue })
    hl("StlPink", { fg = pal.pink })
    hl("StlMuted", { fg = p.overlay0 })
    hl("StlFile", { fg = p.overlay2 })
    hl("StlAdd", { fg = pal.git_add })
    hl("StlDel", { fg = pal.git_delete })
    hl("StlErr", { fg = p.red })
    hl("StlWarn", { fg = p.yellow })
    hl("StlInfo", { fg = pal.blue })
    hl("StlHint", { fg = p.overlay2 })
end
set_hl()

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_hl })

local redraw = vim.schedule_wrap(function()
    pcall(vim.cmd.redrawstatus)
end)

-- Client names per buffer, invalidated on attach/detach instead of rebuilt per render.
local lsp_names = {}
vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "BufWipeout" }, {
    group = group,
    callback = function(args)
        lsp_names[args.buf] = nil
        redraw()
    end,
})

local function clients(buf)
    if lsp_names[buf] == nil then
        local names = {}
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
            names[#names + 1] = c.name
        end
        lsp_names[buf] = table.concat(names, " ")
    end
    return lsp_names[buf]
end

-- LSP progress (replaces fidget): last message, cleared shortly after `end`.
local SPINNER = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local progress, spin, progress_gen = "", 0, 0
vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function(args)
        local v = args.data.params.value
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        progress_gen = progress_gen + 1
        if v.kind == "end" then
            progress = "✓ " .. (client and client.name or "")
            local mine = progress_gen
            vim.defer_fn(function()
                if mine == progress_gen then
                    progress = ""
                    redraw()
                end
            end, 1000)
        else
            spin = spin % #SPINNER + 1
            local pct = v.percentage and (" %d%%"):format(v.percentage) or ""
            progress = SPINNER[spin] .. " " .. (v.title or (client and client.name) or "") .. pct
        end
        redraw()
    end,
})

-- searchcount() rescans the buffer; cache it per cursor move / new search. Skip in
-- huge buffers: a sparse pattern scans the whole file (~24ms/move at 200k lines).
local SEARCHCOUNT_MAX_LINES = 20000
local search = ""
vim.api.nvim_create_autocmd({ "CursorMoved", "CmdlineLeave" }, {
    group = group,
    callback = function()
        search = ""
        if vim.v.hlsearch == 1 and vim.api.nvim_buf_line_count(0) <= SEARCHCOUNT_MAX_LINES then
            local ok, s = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 30 })
            if ok and s.total and s.total > 0 then
                search = ("[%d/%d]"):format(s.current, s.total)
            end
        end
    end,
})

vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave", "DiagnosticChanged" }, {
    group = group,
    callback = redraw,
})
vim.api.nvim_create_autocmd("User", { group = group, pattern = "GitSignsUpdate", callback = redraw })

local function esc(s)
    return (s:gsub("%%", "%%%%"))
end

local function seg(hl, text)
    return "%#" .. hl .. "#" .. text
end

local DIAG = {
    { vim.diagnostic.severity.ERROR, "StlErr", "E" },
    { vim.diagnostic.severity.WARN, "StlWarn", "W" },
    { vim.diagnostic.severity.INFO, "StlInfo", "I" },
    { vim.diagnostic.severity.HINT, "StlHint", "H" },
}

local M = {}

function M.render()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype == "snacks_dashboard" then
        return ""
    end
    local mode = MODES[vim.api.nvim_get_mode().mode] or MODES[vim.fn.mode()] or { "???", "C" }
    local l = { seg("StlMode" .. mode[2], " " .. mode[1]) }

    local reg = vim.fn.reg_recording()
    if reg ~= "" then
        l[#l + 1] = seg("StlPink", "@" .. reg)
    end
    local git = vim.b[buf].gitsigns_status_dict
    if git and git.head and git.head ~= "" then
        l[#l + 1] = seg("StlBlue", " " .. esc(git.head))
    end

    local name = vim.api.nvim_buf_get_name(buf)
    name = name == "" and "[scratch]" or vim.fn.fnamemodify(name, ":~:.")
    local flags = (vim.bo[buf].modified and " [+]" or "")
        .. ((vim.bo[buf].readonly or not vim.bo[buf].modifiable) and " [RO]" or "")
    l[#l + 1] = seg("StlFile", esc(name)) .. seg("StlPink", flags)

    local counts = vim.diagnostic.count(buf)
    local d = {}
    for _, s in ipairs(DIAG) do
        local n = counts[s[1]]
        if n and n > 0 then
            d[#d + 1] = seg(s[2], s[3] .. n)
        end
    end
    if #d > 0 then
        l[#l + 1] = table.concat(d, " ")
    end

    local r = {}
    if progress ~= "" then
        r[#r + 1] = seg("StlMuted", esc(progress))
    end
    local names = clients(buf)
    if names ~= "" then
        r[#r + 1] = seg("StlBlue", names)
    end
    if git then
        local g = {}
        if (git.added or 0) > 0 then
            g[#g + 1] = seg("StlAdd", "+" .. git.added)
        end
        if (git.changed or 0) > 0 then
            g[#g + 1] = seg("StlPink", "~" .. git.changed)
        end
        if (git.removed or 0) > 0 then
            g[#g + 1] = seg("StlDel", "-" .. git.removed)
        end
        if #g > 0 then
            r[#r + 1] = table.concat(g, " ")
        end
    end
    -- Surface non-default encoding / line-ending (mojibake / CRLF).
    local enc, ff = vim.bo[buf].fileencoding, vim.bo[buf].fileformat
    if (enc ~= "" and enc ~= "utf-8") or ff ~= "unix" then
        r[#r + 1] = seg("StlPink", (enc ~= "utf-8" and enc .. " " or "") .. ff)
    end
    if vim.v.hlsearch == 1 and search ~= "" then
        r[#r + 1] = seg("StlMuted", search)
    end
    r[#r + 1] = seg("StlFile", "%l:%c") .. seg("StlMuted", " %P ")

    return table.concat(l, "  ") .. "%#StatusLine#%=" .. table.concat(r, "  ")
end

vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

return M
