# Prints "Yo" to stdout, exits 0
.global _start
.section .rodata
msg: .ascii "Yo"
.section .text
_start:
    mov $1, %rax
    mov $1, %rdi
    lea msg(%rip), %rsi
    mov $2, %rdx
    syscall
    mov $60, %rax
    xor %rdi, %rdi
    syscall
