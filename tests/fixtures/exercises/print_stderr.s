.global _start
.text

_start:
    # Write "Error" to stderr (fd 2)
    movq $1, %rax           # sys_write
    movq $2, %rdi           # fd = stderr
    leaq msg(%rip), %rsi
    movq $5, %rdx           # len
    syscall

    movq $60, %rax          # sys_exit
    xor %rdi, %rdi
    syscall

.section .rodata
msg: .ascii "Error"
