-- Shared LuaSnip locals for snippets/*.lua. Pull only the names a file uses:
--   local u = require("config.snippets")
--   local s, i, fmt = u.s, u.i, u.fmt
local ls = require("luasnip")

local M = {}

M.s = ls.snippet
M.i = ls.insert_node
M.f = ls.function_node
M.rep = require("luasnip.extras").rep
M.fmt = require("luasnip.extras.fmt").fmt

-- fmt with `<>` delimiters so literal `{}`/`{{ }}` braces pass through.
function M.fmtd(str, nodes)
    return M.fmt(str, nodes, { delimiters = "<>" })
end

function M.today()
    return os.date("%Y-%m-%d")
end

-- Nanosecond seed avoids same-second UUID collisions.
math.randomseed((vim.uv or vim.loop).hrtime() % 2147483647)
function M.uuid()
    return (
        string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function(c)
            local r = math.random(0, 15)
            local v = (c == "x") and r or (r % 4 + 8)
            return string.format("%x", v)
        end)
    )
end

return M
