local u = require("config.snippets")
-- `f` uses `<>` delimiters so `{}` braces stay literal.
local s, i, f = u.s, u.i, u.fmtd

return {
    s("ver", f("#version <>", { i(0, "450") })),
    s(
        "main",
        f(
            [[
void main() {
    <>
}]],
            { i(0) }
        )
    ),
    s(
        "frag",
        f(
            [[
#version 450
layout(location = 0) out vec4 FragColor;

void main() {
    FragColor = vec4(<>);
}]],
            { i(0, "1.0, 1.0, 1.0, 1.0") }
        )
    ),
    s(
        "vert",
        f(
            [[
#version 450
layout(location = 0) in vec3 aPos;

void main() {
    gl_Position = vec4(aPos, 1.0);
}]],
            {}
        )
    ),
    s("uni", f("uniform <> <>;", { i(1, "vec3"), i(0, "name") })),
    s("in", f("layout(location = <>) in <> <>;", { i(1, "0"), i(2, "vec3"), i(0, "aPos") })),
    s("out", f("layout(location = <>) out <> <>;", { i(1, "0"), i(2, "vec4"), i(0, "FragColor") })),
    s(
        "comp",
        f(
            [[
#version 450
layout(local_size_x = <>) in;

void main() {
    <>
}]],
            { i(1, "64"), i(0) }
        )
    ),
}
