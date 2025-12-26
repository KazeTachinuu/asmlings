# Prints first command-line argument (AT&T syntax)
# argc is at (%rsp), argv at 8(%rsp), argv[1] at 16(%rsp)
.global _start
.section .text
_start:
    # Check argc >= 2
    movq (%rsp), %rax
    cmpq $2, %rax
    jl .no_arg

    # Get argv[1]
    movq 16(%rsp), %rsi

    # Get string length
    movq %rsi, %rdi
    xorq %rcx, %rcx
.strlen:
    cmpb $0, (%rdi, %rcx)
    je .got_len
    incq %rcx
    jmp .strlen
.got_len:
    movq %rcx, %rdx             # length

    # write(1, argv[1], len)
    movq $1, %rax
    movq $1, %rdi
    syscall

    # exit(0)
    movq $60, %rax
    xorq %rdi, %rdi
    syscall

.no_arg:
    movq $60, %rax
    movq $1, %rdi
    syscall
