local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local function uuid_v4()
    math.randomseed(os.time() + math.floor((os.clock() or 0) * 1e6))
    return (
        string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function(c)
            local r = math.random(0, 15)
            local v = (c == "x") and r or (r % 4 + 8)
            return string.format("%x", v)
        end)
    )
end

local function today()
    return os.date("%Y-%m-%d")
end

return {
    s("date", f(today)),
    s(
        "datetime",
        f(function()
            return os.date("%Y-%m-%d %H:%M:%S")
        end)
    ),
    s(
        "iso",
        f(function()
            return os.date("!%Y-%m-%dT%H:%M:%SZ")
        end)
    ),
    s("uuid", f(uuid_v4)),
    s("todo", fmt("TODO({}): {}", { f(today), i(0) })),
    s("fixme", fmt("FIXME({}): {}", { f(today), i(0) })),
    s("note", fmt("NOTE({}): {}", { f(today), i(0) })),
}
