-- cmd / filetypes / root_markers come from nvim-lspconfig's bundled config.
return {
    settings = {
        intelephense = {
            files = {
                -- Default 1 MiB skips large vendored files; bump for big frameworks.
                maxSize = 5000000,
            },
        },
    },
}
