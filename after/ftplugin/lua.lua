-- stylua column_width guide; tracks a project stylua.toml, else default 120.
require("config.format-width").guide({
    { names = { "stylua.toml", ".stylua.toml" }, pattern = "^%s*column_width%s*=%s*(%d+)" },
}, 120)
