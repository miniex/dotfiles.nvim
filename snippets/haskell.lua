local u = require("config.snippets")
local s, i, fmt, rep = u.s, u.i, u.fmt, u.rep

return {
    -- module declaration
    s("mod", fmt("module {} ({}) where\n\n{}", { i(1, "Main"), i(2), i(0) })),
    -- main
    s("main", fmt("main :: IO ()\nmain = {}", { i(0, 'putStrLn "hello"') })),
    -- function with type signature (name repeated on the definition line)
    s("fn", fmt("{} :: {}\n{} {} = {}", { i(1, "name"), i(2, "a -> a"), rep(1), i(3, "x"), i(0) })),
    -- data type
    s("data", fmt("data {} = {}", { i(1, "Name"), i(0, "Constructor") })),
    -- import / qualified import
    s("imp", fmt("import {}", { i(0, "Data.List") })),
    s("impq", fmt("import qualified {} as {}", { i(1, "Data.Map"), i(0, "Map") })),
    -- case expression
    s("case", fmt("case {} of\n  {} -> {}", { i(1, "x"), i(2, "_"), i(0) })),
    -- let ... in
    s("let", fmt("let {} = {}\n in {}", { i(1, "x"), i(2), i(0) })),
    -- typeclass / instance
    s("class", fmt("class {} where\n  {}", { i(1, "Name a"), i(0) })),
    s("inst", fmt("instance {} where\n  {}", { i(1, "Show a"), i(0) })),
}
