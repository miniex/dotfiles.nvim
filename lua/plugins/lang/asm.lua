return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- asm-lsp covers x86/x86_64 (GAS, NASM, MASM), ARM/AArch64,
                -- RISC-V, MIPS, PowerPC, Z80, 6502, AVR.
                asm_lsp = {
                    filetypes = { "asm", "vmasm", "nasm", "masm" },
                },
            },
        },
    },
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
