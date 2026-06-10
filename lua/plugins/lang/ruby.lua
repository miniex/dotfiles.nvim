-- Grammar (ruby) in the base treesitter list; ruby_lsp via lang_servers.
-- Debugging uses the `debug` gem (rdbg) — add it per-project: `bundle add debug`.
return {
    { "mfussenegger/nvim-dap", dependencies = { "suketa/nvim-dap-ruby" } },
    require("config.dap").spec(function()
        require("dap-ruby").setup()
    end),
}
