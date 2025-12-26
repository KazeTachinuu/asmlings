# ======================================
# Exercise 23: Your First Loop
# ======================================
#
# A loop is just: do stuff, check condition, jump back.
#
# Pattern:
#   loop_start:
#       # ... do work ...
#       decq %rcx           # decrement counter
#       jnz loop_start      # jump if not zero
#
# decq decrements AND sets flags. If result is zero, ZF=1.
# jnz = "jump if not zero" = loop continues while counter > 0.
#
# YOUR TASK: Complete the loop to add 1 to %rdi five times.
#            Result should be 5.
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $0, %rdi           # Accumulator (result)
    movq $5, %rcx           # Counter

loop_start:
    addq $1, %rdi           # Add 1 to result

    # YOUR CODE HERE:
    # 1. Decrement the counter
    # 2. Jump back to loop_start if counter is not zero


    # When loop ends, rdi should be 5
    movq $60, %rax
    syscall
