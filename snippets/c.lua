local u = require("config.snippets")
local s, i, rep, fmt = u.s, u.i, u.rep, u.fmt

return {
    s("inc", fmt("#include <{}.h>", { i(1, "stdio") })),
    s("incl", fmt('#include "{}.h"', { i(1, "header") })),
    s("guard", fmt("#ifndef {}_H\n#define {}_H\n\n{}\n\n#endif /* {}_H */", { i(1, "NAME"), rep(1), i(0), rep(1) })),
    s(
        "main",
        fmt("#include <stdio.h>\n\nint main(int argc, char **argv) {{\n    {}\n    return 0;\n}}", {
            i(0, 'printf("hello\\n");'),
        })
    ),
    s("fn", fmt("{} {}({}) {{\n    {}\n}}", { i(1, "void"), i(2, "name"), i(3), i(0) })),
    s("ts", fmt("typedef struct {} {{\n    {}\n}} {};", { i(1, "Tag"), i(2), i(3, "Name") })),
    s("for", fmt("for (int {} = 0; {} < {}; ++{}) {{\n    {}\n}}", { i(1, "i"), rep(1), i(2, "n"), rep(1), i(0) })),
}
