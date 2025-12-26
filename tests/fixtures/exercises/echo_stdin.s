# Reads from stdin and writes to stdout (like cat)
.global _start
.section .bss
buf: .skip 256
.section .text
_start:
    # read(0, buf, 256)
    xor %rax, %rax
    xor %rdi, %rdi
    lea buf(%rip), %rsi
    mov $256, %rdx
    syscall
    mov %rax, %r12              # save bytes read

    # write(1, buf, bytes_read)
    mov $1, %rax
    mov $1, %rdi
    lea buf(%rip), %rsi
    mov %r12, %rdx
    syscall

    # exit(0)
    mov $60, %rax
    xor %rdi, %rdi
    syscall
