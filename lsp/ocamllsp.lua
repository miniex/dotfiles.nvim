return {
    filetypes = {
        "ocaml",
        "ocaml.menhir",
        "ocaml.interface",
        "ocaml.ocamllex",
        "reason",
        "dune",
    },
    settings = {
        codelens = { enable = true },
        inlayHints = { enable = true },
        syntaxDocumentation = { enable = true },
        extendedHover = { enable = true },
    },
    get_language_id = function(_, lang)
        local map = {
            ocaml = "ocaml",
            ["ocaml.menhir"] = "ocaml.menhir",
            ["ocaml.interface"] = "ocaml.interface",
            ["ocaml.ocamllex"] = "ocaml.ocamllex",
            reason = "reason",
            dune = "dune",
        }
        return map[lang] or lang
    end,
}
