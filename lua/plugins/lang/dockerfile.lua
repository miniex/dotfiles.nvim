-- nvim detects compose files as plain "yaml"; tag them "yaml.docker-compose"
-- so docker_compose_language_service attaches.
vim.filetype.add({
    filename = {
        ["compose.yaml"] = "yaml.docker-compose",
        ["compose.yml"] = "yaml.docker-compose",
        ["docker-compose.yaml"] = "yaml.docker-compose",
        ["docker-compose.yml"] = "yaml.docker-compose",
    },
    pattern = {
        ["[Cc]ompose%.[^.]*%.ya?ml"] = "yaml.docker-compose",
        ["docker%-compose%.[^.]*%.ya?ml"] = "yaml.docker-compose",
    },
})

return {}
