# Exits with argc as exit code
.global _start
.text
_start:
    movq (%rsp), %rdi       # argc
    movq $60, %rax
    syscall
