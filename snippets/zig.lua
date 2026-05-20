local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s(
        "main",
        fmt(
            [[
const std = @import("std");

pub fn main() !void {{
    {}
}}
]],
            { i(0, 'std.debug.print("hello\\n", .{});') }
        )
    ),
    s("imp", fmt('const {} = @import("{}");', { i(1, "std"), i(0, "std") })),
    s("fn", fmt("pub fn {}({}) {} {{\n    {}\n}}", { i(1, "name"), i(2), i(3, "!void"), i(0) })),
    s(
        "st",
        fmt(
            [[
const {} = struct {{
    {}: {},

    pub fn init({}: {}) {} {{
        return .{{ .{} = {} }};
    }}
}};
]],
            {
                i(1, "Name"),
                i(2, "field"),
                i(3, "u32"),
                i(4, "v"),
                i(5, "u32"),
                i(6, "Name"),
                i(7, "field"),
                i(0, "v"),
            }
        )
    ),
    s("tst", fmt('test "{}" {{\n    {}\n}}', { i(1, "name"), i(0, "try std.testing.expect(true);") })),
    s("def", fmt("defer {};", { i(0) })),
    s("edef", fmt("errdefer {};", { i(0) })),
    s("try", fmt("try {};", { i(0) })),
    s(
        "alloc",
        fmt(
            [[
var gpa = std.heap.GeneralPurposeAllocator(.{{}}){{}};
defer _ = gpa.deinit();
const {} = gpa.allocator();
{}
]],
            { i(1, "allocator"), i(0) }
        )
    ),
    s("sw", fmt("switch ({}) {{\n    .{} => {},\n    else => {},\n}}", { i(1), i(2, "tag"), i(3), i(0) })),
}
