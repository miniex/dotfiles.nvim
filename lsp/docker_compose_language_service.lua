-- Attaches to the "yaml.docker-compose" filetype (set in plugins/lang/dockerfile.lua).
-- root_markers replace the default, so re-add .git as a fallback root.
return {
    filetypes = { "yaml.docker-compose" },
    root_markers = {
        "docker-compose.yaml",
        "docker-compose.yml",
        "compose.yaml",
        "compose.yml",
        ".git",
    },
}
