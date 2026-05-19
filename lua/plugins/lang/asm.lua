-- asm-lsp server config lives in lsp/asm_lsp.lua.
return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "asm", "nasm" })
            -- No dedicated MASM/vmasm grammars; fall back to the generic asm parser.
            vim.treesitter.language.register("asm", { "masm", "vmasm" })
        end,
    },
}
