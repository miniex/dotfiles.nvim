return {
    -- .mli is ft=ocaml, so the ocaml parser handles it (ocaml_interface would be unused).
    require("config.lang").treesitter({ "ocaml" }),
}
