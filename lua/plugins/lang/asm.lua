-- asm-lsp server config lives in lsp/asm_lsp.lua.
return {
    -- No dedicated MASM/vmasm grammars; fall back to the generic asm parser.
    require("config.lang").treesitter({ "asm", "nasm" }, { asm = { "masm" } }),
}
