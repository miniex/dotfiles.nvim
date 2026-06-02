local u = require("config.snippets")
local s, i, f, fmt, today, uuid = u.s, u.i, u.f, u.fmt, u.today, u.uuid

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
    s("uuid", f(uuid)),
    s("todo", fmt("TODO({}): {}", { f(today), i(0) })),
    s("fixme", fmt("FIXME({}): {}", { f(today), i(0) })),
    s("note", fmt("NOTE({}): {}", { f(today), i(0) })),
}
