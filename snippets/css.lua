local u = require("config.snippets")
-- fmtd: `<>` delimiters so literal `{ }` braces pass through.
local s, i, fmtd = u.s, u.i, u.fmtd

return {
    s(
        "flex",
        fmtd(
            [[display: flex;
align-items: <>;
justify-content: <>;]],
            { i(1, "center"), i(2, "center") }
        )
    ),
    s(
        "grid",
        fmtd(
            [[display: grid;
grid-template-columns: <>;
gap: <>;]],
            { i(1, "1fr"), i(2, "1rem") }
        )
    ),
    s(
        "media",
        fmtd(
            [[@media (max-width: <>) {
    <>
}]],
            { i(1, "768px"), i(0) }
        )
    ),
    s("trans", fmtd("transition: <> <> ease;", { i(1, "all"), i(2, "0.2s") })),
    s("var", fmtd("--<>: <>;", { i(1, "name"), i(2, "value") })),
}
