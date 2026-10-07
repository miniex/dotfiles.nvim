-- svelte LSP (lang_servers) + treesitter are wired centrally.
return {
    require("config.lang").treesitter({ "svelte", "html", "css", "javascript", "typescript" }),
}
