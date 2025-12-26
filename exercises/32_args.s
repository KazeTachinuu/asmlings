# ======================================
# Exercise 32: Function Arguments - Calling Convention
# ======================================
#
# System V AMD64 ABI (Linux calling convention):
#
# Arguments (in order): %rdi, %rsi, %rdx, %rcx, %r8, %r9
# Return value:         %rax
#
# func(a, b, c) ->  a in %rdi, b in %rsi, c in %rdx
#
# YOUR TASK:
#   1. Set up arguments for add(25, 19)
#   2. Complete the add function to return the sum
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    # YOUR CODE HERE: Set up arguments for add(25, 19)
    # First argument (25) goes in %rdi
    # Second argument (19) goes in %rsi


    call add

    movq %rax, %rdi         # Move return value to exit code
    movq $60, %rax
    syscall

add:
    pushq %rbp
    movq %rsp, %rbp

    # YOUR CODE HERE:
    # Add the two arguments and store result in %rax
    # Arguments are in %rdi and %rsi


    popq %rbp
    ret
