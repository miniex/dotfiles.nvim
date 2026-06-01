-- taplo column_width guide; tracks taplo.toml, else default 80.
require("config.format-width").guide({
    { names = { "taplo.toml", ".taplo.toml" }, pattern = "^%s*column_width%s*=%s*(%d+)" },
}, 80)
