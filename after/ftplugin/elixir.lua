-- mix format line_length guide; tracks .formatter.exs, else default 98.
require("config.format-width").guide({
    { names = { ".formatter.exs" }, pattern = "line_length%s*:%s*(%d+)" },
}, 98)
