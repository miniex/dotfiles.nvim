local u = require("config.snippets")
local s, i, f, fmt = u.s, u.i, u.f, u.fmt

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
}
