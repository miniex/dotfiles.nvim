-- Filetypes stay bundled: nvim detects .mli/.mly/.mll as `ocaml`, and lspconfig's
-- get_language_id sends ocaml.interface / menhir / ocamllex from the extension.
return {
    settings = {
        codelens = { enable = true },
        inlayHints = { enable = true },
        syntaxDocumentation = { enable = true },
        extendedHover = { enable = true },
    },
}
