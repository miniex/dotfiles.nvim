-- Root at the app dir (svelte.config.*), not the monorepo lockfile root the bundled config
-- picks. Needs root_dir (not root_markers) to override the bundle's own root_dir.
return {
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        -- Svelte LSP only supports the file:// scheme; skip unsaved/virtual buffers.
        if (vim.uv or vim.loop).fs_stat(fname) == nil then
            return
        end
        local root = vim.fs.root(bufnr, { "svelte.config.js", "svelte.config.mjs", "svelte.config.cjs" })
            or vim.fs.root(bufnr, "package.json")
            or vim.fs.root(
                bufnr,
                { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", "deno.lock", ".git" }
            )
            or vim.fn.getcwd()
        on_dir(root)
    end,
}
