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
                -- Extra parens truncate gsub's 2nd return (count) to the string only.
                return ((a[1][1] or ""):gsub("^%l", string.upper))
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
    s(
        "uc",
        fmt(
            [[const {} = useCallback(() => {{
    {}
}}, [{}]);]],
            { i(1, "fn"), i(2), i(0) }
        )
    ),
    s("um", fmt("const {} = useMemo(() => {}, [{}]);", { i(1, "value"), i(2), i(0) })),
    s("ur", fmt("const {} = useRef<{}>({});", { i(1, "ref"), i(2, "HTMLDivElement"), i(0, "null") })),
    s("urd", fmt("const [{}, dispatch] = useReducer({}, {});", { i(1, "state"), i(2, "reducer"), i(0, "initial") })),
}
