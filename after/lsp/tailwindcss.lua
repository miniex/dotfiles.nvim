-- classRegex teaches the LSP about utility wrappers (cva / clsx / cn / tw).
return {
    -- The bundled root_dir minus its .git fallback, which attached to every repo:
    -- a config file, package.json / mix.lock / Gemfile.lock naming tailwind (v4).
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local files = {
            "tailwind.config.js",
            "tailwind.config.cjs",
            "tailwind.config.mjs",
            "tailwind.config.ts",
            "postcss.config.js",
            "postcss.config.cjs",
            "postcss.config.mjs",
            "postcss.config.ts",
            -- Django (django-tailwind)
            "theme/static_src/tailwind.config.js",
            "theme/static_src/tailwind.config.cjs",
            "theme/static_src/tailwind.config.mjs",
            "theme/static_src/tailwind.config.ts",
            "theme/static_src/postcss.config.js",
        }
        local util = require("lspconfig.util")
        files = util.insert_package_json(files, "tailwindcss", fname)
        files = util.root_markers_with_field(files, { "mix.lock", "Gemfile.lock" }, "tailwind", fname)
        local found = vim.fs.find(files, { path = fname, upward = true })[1]
        if found then
            on_dir(vim.fs.dirname(found))
        end
    end,
    settings = {
        tailwindCSS = {
            experimental = {
                classRegex = {
                    { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                    { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                    { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                    { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                    { "tw`([^`]*)" },
                    { 'tw="([^"]*)' },
                    { 'tw={"([^"}]*)' },
                },
            },
        },
    },
}
