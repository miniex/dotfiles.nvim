-- ocamlformat margin guide; tracks .ocamlformat, else default 80.
require("config.format-width").guide({
    { names = { ".ocamlformat" }, pattern = "^%s*margin%s*=%s*(%d+)" },
}, 80)
