# Read stdin then infinite loop
.global _start
.text

_start:
    # Read from stdin
    movq $0, %rax           # sys_read
    movq $0, %rdi           # stdin
    leaq buf(%rip), %rsi    # buffer
    movq $10, %rdx          # count
    syscall

    # Infinite loop after reading
loop:
    jmp loop

.section .bss
buf: .skip 16
