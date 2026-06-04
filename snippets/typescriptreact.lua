local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

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
    s("us", fmt("const [{}, set{}] = useState({});", { i(1, "state"), i(2, "State"), i(3) })),
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
