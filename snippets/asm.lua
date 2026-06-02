local u = require("config.snippets")
local s, i, fmt = u.s, u.i, u.fmt

return {
    -- x86-64 Linux skeleton (GAS/NASM-agnostic section names).
    s(
        "prog",
        fmt(
            [[
.section .data
{}
.section .text
.globl _start
_start:
    {}
    mov $60, %rax
    xor %rdi, %rdi
    syscall
]],
            { i(1), i(0) }
        )
    ),
    s("text", fmt(".section .text\n.globl {}\n{}:\n    {}", { i(1, "_start"), i(2, "_start"), i(0) })),
    s("data", fmt(".section .data\n{}", { i(0) })),
    s("bss", fmt(".section .bss\n{}", { i(0) })),
    s("glob", fmt(".globl {}", { i(0, "_start") })),
    s("fn", fmt("{}:\n    push %rbp\n    mov %rsp, %rbp\n    {}\n    pop %rbp\n    ret", { i(1, "name"), i(0) })),
    s("sys", fmt("mov ${}, %rax\n    syscall", { i(0, "1") })),
    s("exit", fmt("mov $60, %rax\n    mov ${}, %rdi\n    syscall", { i(0, "0") })),
}
