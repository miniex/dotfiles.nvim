local u = require("config.snippets")
local s, i, fmt, f = u.s, u.i, u.fmt, u.f

-- tsx-only; ts/js snippets are inherited via ls.filetype_extend (completion.lua).
return {
    -- functional component
    s(
        "rfc",
        fmt(
            [[export default function {}() {{
    return (
        <div>{}</div>
    );
}}]],
            { i(1, "Component"), i(0) }
        )
    ),
    -- setter name mirrors + capitalizes the state name
    s(
        "us",
        fmt("const [{}, set{}] = useState({});", {
            i(1, "state"),
            f(function(a)
                return (a[1][1] or ""):gsub("^%l", string.upper)
            end, { 1 }),
            i(2),
        })
    ),
    s(
        "ue",
        fmt(
            [[useEffect(() => {{
    {}
}}, [{}]);]],
            { i(1), i(2) }
        )
    ),
}
