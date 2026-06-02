local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

return {
    s("exe", fmt("(executable\n (name {})\n (libraries {}))", { i(1, "main"), i(0) })),
    s("lib", fmt("(library\n (name {})\n (libraries {}))", { i(1, "mylib"), i(0) })),
    s("test", fmt("(test\n (name {})\n (libraries {}))", { i(1, "test_main"), i(0, "alcotest") })),
    s("rule", fmt("(rule\n (target {})\n (deps {})\n (action {}))", { i(1, "out"), i(2, "in"), i(0) })),
    -- dune-project
    s("proj", fmt("(lang dune {})", { i(0, "3.0") })),
}
