# Prints "A\nB\nC" (multiline)
.global _start
.section .data
msg: .ascii "A\nB\nC"
msglen = . - msg
.section .text
_start:
    # write(1, msg, msglen)
    mov $1, %rax
    mov $1, %rdi
    lea msg(%rip), %rsi
    mov $msglen, %rdx
    syscall

    # exit(0)
    mov $60, %rax
    xor %rdi, %rdi
    syscall
