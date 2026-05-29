local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s("min", fmt("cmake_minimum_required(VERSION {})", { i(0, "3.20") })),
    s("proj", fmt("project({} LANGUAGES {})", { i(1, "name"), i(0, "CXX") })),
    s("exe", fmt("add_executable({} {})", { i(1, "name"), i(0, "main.cpp") })),
    s("lib", fmt("add_library({} {} {})", { i(1, "name"), i(2, "STATIC"), i(0, "src.cpp") })),
    s("inc", fmt("target_include_directories({} {} {})", { i(1, "target"), i(2, "PUBLIC"), i(0, "include") })),
    s("link", fmt("target_link_libraries({} {} {})", { i(1, "target"), i(2, "PRIVATE"), i(0, "deps") })),
    s("find", fmt("find_package({} REQUIRED)", { i(0, "pkg") })),
    s("set", fmt("set({} {})", { i(1, "VAR"), i(0, "value") })),
    s("opt", fmt('option({} "{}" {})', { i(1, "NAME"), i(2, "description"), i(0, "ON") })),
    s("if", fmt("if({})\n  {}\nendif()", { i(1, "condition"), i(0) })),
    s("foreach", fmt("foreach({} {})\n  {}\nendforeach()", { i(1, "item"), i(2, "items"), i(0) })),
    s("func", fmt("function({})\n  {}\nendfunction()", { i(1, "name"), i(0) })),
}
