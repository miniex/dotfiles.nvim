-- sqlfluff max_line_length guide; tracks .sqlfluff / pyproject.toml, else default 80.
require("config.format-width").guide({
    { names = { ".sqlfluff" }, pattern = "^%s*max_line_length%s*=%s*(%d+)" },
    { names = { "pyproject.toml" }, pattern = "^%s*max_line_length%s*=%s*(%d+)" },
}, 80)
