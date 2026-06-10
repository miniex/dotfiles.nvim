-- asm-lsp: x86, ARM, RISC-V, MIPS, PowerPC, Z80, 6502, AVR.
return {
    -- bundled { asm, vmasm } + nasm + masm (treesitter alias, lang/asm.lua).
    filetypes = { "asm", "nasm", "vmasm", "masm" },
}
