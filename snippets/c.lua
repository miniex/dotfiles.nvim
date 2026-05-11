local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- include
    s("inc", fmt("#include <{}.h>", { i(1, "stdio") })),
    s("incl", fmt('#include "{}.h"', { i(1, "header") })),
    -- header guard
    s("guard", fmt("#ifndef {}_H\n#define {}_H\n\n{}\n\n#endif /* {}_H */", { i(1, "NAME"), i(1), i(0), i(1) })),
    -- main
    s(
        "main",
        fmt("#include <stdio.h>\n\nint main(int argc, char **argv) {{\n    {}\n    return 0;\n}}", {
            i(0, 'printf("hello\\n");'),
        })
    ),
    -- function
    s("fn", fmt("{} {}({}) {{\n    {}\n}}", { i(1, "void"), i(2, "name"), i(3), i(0) })),
    -- struct typedef
    s("ts", fmt("typedef struct {} {{\n    {}\n}} {};", { i(1, "Tag"), i(2), i(3, "Name") })),
    -- for loop
    s("for", fmt("for (int {} = 0; {} < {}; ++{}) {{\n    {}\n}}", { i(1, "i"), i(1), i(2, "n"), i(1), i(0) })),
}
