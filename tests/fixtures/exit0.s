# Exits with code 0
.global _start
.text
_start:
    mov $60, %rax
    xor %rdi, %rdi
    syscall
