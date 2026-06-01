-- ruff/black line-length guide; tracks project config, else PEP 8 default 88.
require("config.format-width").guide({
    { names = { "ruff.toml", ".ruff.toml" }, pattern = "^%s*line%-length%s*=%s*(%d+)" },
    { names = { "pyproject.toml" }, pattern = "^%s*line%-length%s*=%s*(%d+)" },
}, 88)
