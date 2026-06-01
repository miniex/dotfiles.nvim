-- rustfmt max_width guide; tracks a project rustfmt.toml, else default 100.
require("config.format-width").guide({
    { names = { "rustfmt.toml", ".rustfmt.toml" }, pattern = "^%s*max_width%s*=%s*(%d+)" },
}, 100)
