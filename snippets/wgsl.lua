local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
-- `{}` fmt delimiters (not `<>`): WGSL uses `<>` itself (vec3<f32>), so `{`/`}` escape as `{{`/`}}`.

return {
    s(
        "vert",
        fmt(
            [[
@vertex
fn vs_main(@location(0) pos: vec3<f32>) -> @builtin(position) vec4<f32> {{
    return vec4<f32>(pos, 1.0);
}}]],
            {}
        )
    ),
    s(
        "frag",
        fmt(
            [[
@fragment
fn fs_main() -> @location(0) vec4<f32> {{
    return vec4<f32>({});
}}]],
            { i(0, "1.0, 1.0, 1.0, 1.0") }
        )
    ),
    s(
        "compute",
        fmt(
            [[
@compute @workgroup_size({})
fn cs_main(@builtin(global_invocation_id) id: vec3<u32>) {{
    {}
}}]],
            { i(1, "8, 8, 1"), i(0) }
        )
    ),
    s(
        "struct",
        fmt(
            [[
struct {} {{
    {}: {},
}}]],
            { i(1, "Name"), i(2, "field"), i(0, "f32") }
        )
    ),
    s(
        "bind",
        fmt("@group({}) @binding({}) var<uniform> {}: {};", { i(1, "0"), i(2, "0"), i(3, "name"), i(0, "Type") })
    ),
    s(
        "fn",
        fmt(
            [[
fn {}({}) -> {} {{
    {}
}}]],
            { i(1, "name"), i(2), i(3, "f32"), i(0) }
        )
    ),
}
