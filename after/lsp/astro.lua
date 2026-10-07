return {
    root_markers = { "astro.config.mjs", "astro.config.ts", "astro.config.js", "package.json", ".git" },
    -- astro-ls won't start without a tsdk; before `npm install` there is no local
    -- typescript, so fall back to the copy mason ships with the server.
    before_init = function(_, config)
        config.init_options = config.init_options or {}
        config.init_options.typescript = config.init_options.typescript or {}
        local ts = config.init_options.typescript
        if not ts.tsdk or ts.tsdk == "" then
            local tsdk = require("lspconfig.util").get_typescript_server_path(config.root_dir)
            if tsdk == "" then
                tsdk = vim.fn.stdpath("data") .. "/mason/packages/astro-language-server/node_modules/typescript/lib"
            end
            ts.tsdk = tsdk
        end
    end,
}
