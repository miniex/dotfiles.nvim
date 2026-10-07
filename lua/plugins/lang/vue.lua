-- vue_ls + treesitter wired centrally; vtsls handles the .vue <script> (hybrid).
return {
    require("config.lang").treesitter({ "vue", "html", "css", "javascript", "typescript" }),
}
