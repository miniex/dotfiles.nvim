-- astro LSP (lang_servers) + treesitter are wired centrally.
return {
    require("config.lang").treesitter({ "astro", "html", "css", "javascript", "typescript", "tsx" }),
}
