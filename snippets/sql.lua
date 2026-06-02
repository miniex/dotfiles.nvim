local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

return {
    s("sel", fmt("SELECT {}\nFROM {};", { i(1, "*"), i(0, "table") })),
    s("selw", fmt("SELECT {}\nFROM {}\nWHERE {};", { i(1, "*"), i(2, "table"), i(0, "condition") })),
    s("ins", fmt("INSERT INTO {} ({})\nVALUES ({});", { i(1, "table"), i(2, "cols"), i(0, "vals") })),
    s("upd", fmt("UPDATE {}\nSET {}\nWHERE {};", { i(1, "table"), i(2, "col = val"), i(0, "condition") })),
    s("del", fmt("DELETE FROM {}\nWHERE {};", { i(1, "table"), i(0, "condition") })),
    s(
        "cre",
        fmt(
            [[
CREATE TABLE {} (
  id SERIAL PRIMARY KEY,
  {} {} NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);]],
            { i(1, "table"), i(2, "name"), i(0, "TEXT") }
        )
    ),
    s("idx", fmt("CREATE INDEX {} ON {} ({});", { i(1, "idx_name"), i(2, "table"), i(0, "col") })),
    s("join", fmt("{} JOIN {} ON {} = {}", { i(1, "INNER"), i(2, "table"), i(3, "a.id"), i(0, "b.id") })),
    s(
        "cte",
        fmt("WITH {} AS (\n  {}\n)\nSELECT * FROM {};", { i(1, "cte_name"), i(2, "SELECT ..."), i(0, "cte_name") })
    ),
}
