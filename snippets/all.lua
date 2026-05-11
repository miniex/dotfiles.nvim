local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

return {
    s(
        "date",
        f(function()
            return os.date("%Y-%m-%d")
        end)
    ),
    s(
        "datetime",
        f(function()
            return os.date("%Y-%m-%d %H:%M:%S")
        end)
    ),
}
