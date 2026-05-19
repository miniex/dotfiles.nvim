local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("inc", fmt("#include <{}>", { i(1, "iostream") })),
    s("incl", fmt('#include "{}.hpp"', { i(1, "header") })),
    s(
        "main",
        fmt(
            "#include <iostream>\n\nint main(int argc, char** argv) {{\n    {}\n    return 0;\n}}",
            { i(0, 'std::cout << "hello\\n";') }
        )
    ),
    s(
        "cls",
        fmt(
            "class {} {{\npublic:\n    {}({});\n    ~{}();\n\nprivate:\n    {}\n}};",
            { i(1, "Name"), rep(1), i(2), rep(1), i(0) }
        )
    ),
    s("ns", fmt("namespace {} {{\n\n{}\n\n}}  // namespace {}", { i(1, "name"), i(0), rep(1) })),
    s("for", fmt("for (auto& {} : {}) {{\n    {}\n}}", { i(1, "v"), i(2, "container"), i(0) })),
    s("mu", fmt("auto {} = std::make_unique<{}>({});", { i(1, "ptr"), i(2, "Type"), i(3) })),
    s("ms", fmt("auto {} = std::make_shared<{}>({});", { i(1, "ptr"), i(2, "Type"), i(3) })),
}
