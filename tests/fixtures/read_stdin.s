# Reads from stdin, exits with byte count
.global _start
.section .bss
buf: .skip 64
.section .text
_start:
    xor %rax, %rax
    xor %rdi, %rdi
    lea buf(%rip), %rsi
    mov $64, %rdx
    syscall
    mov %rax, %rdi
    mov $60, %rax
    syscall
