local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

return {
    -- class with initialize
    s("cls", fmt("class {}\n  def initialize({})\n    {}\n  end\nend", { i(1, "Name"), i(2), i(0) })),
    -- method / module
    s("def", fmt("def {}({})\n  {}\nend", { i(1, "name"), i(2), i(0) })),
    s("mod", fmt("module {}\n  {}\nend", { i(1, "Name"), i(0) })),
    -- each / map block
    s("each", fmt("{}.each do |{}|\n  {}\nend", { i(1, "collection"), i(2, "item"), i(0) })),
    s("map", fmt("{}.map do |{}|\n  {}\nend", { i(1, "collection"), i(2, "item"), i(0) })),
    -- if
    s("if", fmt("if {}\n  {}\nend", { i(1, "condition"), i(0) })),
    -- require / attr
    s("req", fmt('require "{}"', { i(0, "set") })),
    s("attr", fmt("attr_accessor :{}", { i(0, "name") })),
    -- RSpec describe / it
    s("desc", fmt('describe "{}" do\n  {}\nend', { i(1, "subject"), i(0) })),
    s("it", fmt('it "{}" do\n  {}\nend', { i(1, "does something"), i(0) })),
}
