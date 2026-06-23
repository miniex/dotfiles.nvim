local u = require("config.snippets")
local s, i, f, fmt, fmtd = u.s, u.i, u.f, u.fmt, u.fmtd

local function tail(args)
    local mod = args[1][1] or ""
    return mod:match("([^.]+)$") or mod
end

return {
    -- local <tail> = require("<module.path>")
    s("req", fmt('local {} = require("{}")', { f(tail, { 1 }), i(1, "module") })),
    -- safe pcall require with early return
    s(
        "preq",
        fmt(
            [[
local ok, {} = pcall(require, "{}")
if not ok then
    return
end
]],
            { f(tail, { 1 }), i(1, "module") }
        )
    ),
    -- local function
    s("lf", fmt("local function {}({})\n    {}\nend", { i(1, "name"), i(2), i(0) })),
    -- module table scaffold
    s("mod", fmt("local M = {{}}\n\n{}\n\nreturn M", { i(0) })),
    -- vim.keymap.set
    s(
        "map",
        fmtd('vim.keymap.set("<>", "<>", <>, { desc = "<>" })', { i(1, "n"), i(2, "lhs"), i(3, "rhs"), i(0, "desc") })
    ),
    -- augroup (clear = true)
    s("aug", fmtd('local <> = vim.api.nvim_create_augroup("<>", { clear = true })', { i(1, "group"), i(2, "name") })),
    -- autocmd
    s(
        "au",
        fmtd(
            'vim.api.nvim_create_autocmd("<>", {\n    group = <>,\n    callback = function(<>)\n        <>\n    end,\n})',
            { i(1, "event"), i(2, "group"), i(3, "args"), i(0) }
        )
    ),
    -- busted describe block
    s("desc", fmtd('describe("<>", function()\n    <>\nend)', { i(1, "name"), i(0) })),
    -- busted it case
    s("it", fmtd('it("<>", function()\n    <>\nend)', { i(1, "description"), i(0) })),
}
