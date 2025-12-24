# Exercise 22: Stack Alignment
#
# Stack MUST be 16-byte aligned before 'call'.
# After pushq %rbp, subtract multiples of 16.
#
# Allocate 16 bytes for locals.
#
# Expected exit code: 0

# I AM NOT DONE

.global _start
.text

_start:
    call my_func
    movq $60, %rax
    xorq %rdi, %rdi
    syscall

my_func:
    pushq %rbp
    movq %rsp, %rbp

    # Subtract 16 for local space

    movq $42, -8(%rbp)

    movq %rbp, %rsp
    popq %rbp
    ret
