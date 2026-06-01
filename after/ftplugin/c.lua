-- clang-format ColumnLimit guide; tracks .clang-format, else default 80.
require("config.format-width").guide({
    { names = { ".clang-format", "_clang-format" }, pattern = "^%s*ColumnLimit%s*:%s*(%d+)" },
}, 80)
