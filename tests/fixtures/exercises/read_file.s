# Reads first argument as filename, outputs content
.global _start
.section .bss
buf: .skip 256
.section .text
_start:
    # Check argc >= 2
    movq (%rsp), %rax
    cmpq $2, %rax
    jl .exit_fail

    # Open file (argv[1])
    movq $2, %rax               # SYS_OPEN
    movq 16(%rsp), %rdi         # argv[1] = filename
    xorq %rsi, %rsi             # O_RDONLY
    xorq %rdx, %rdx
    syscall
    testq %rax, %rax
    js .exit_fail
    movq %rax, %r12             # save fd

    # Read file
    xorq %rax, %rax             # SYS_READ
    movq %r12, %rdi
    leaq buf(%rip), %rsi
    movq $256, %rdx
    syscall
    movq %rax, %r13             # save bytes read

    # Close file
    movq $3, %rax               # SYS_CLOSE
    movq %r12, %rdi
    syscall

    # Write to stdout
    movq $1, %rax               # SYS_WRITE
    movq $1, %rdi
    leaq buf(%rip), %rsi
    movq %r13, %rdx
    syscall

    # Exit 0
    movq $60, %rax
    xorq %rdi, %rdi
    syscall

.exit_fail:
    movq $60, %rax
    movq $1, %rdi
    syscall
