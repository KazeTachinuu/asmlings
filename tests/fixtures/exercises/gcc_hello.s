.intel_syntax noprefix
.global main
.section .rodata
msg: .asciz "Hello"
.section .text
main:
    push rbp
    mov rbp, rsp
    lea rdi, [rip + msg]
    call puts@PLT
    xor eax, eax
    pop rbp
    ret
