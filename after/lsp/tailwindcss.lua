-- classRegex teaches the LSP about utility wrappers (cva / clsx / cn / tw).
return {
    -- The bundled root_dir falls back to .git, attaching to every repo. Tailwind
    -- projects only: a config file or a package.json depending on tailwindcss (v4).
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
        }
        files = require("lspconfig.util").insert_package_json(files, "tailwindcss", fname)
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
