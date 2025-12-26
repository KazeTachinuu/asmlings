# ======================================
# Exercise 30: Leaf Functions
# ======================================
#
# A "leaf function" is a function that doesn't call other functions.
# These functions often don't need a stack frame at all!
#
# System V AMD64 calling convention:
#   Arguments:  %rdi, %rsi, %rdx, %rcx, %r8, %r9
#   Return:     %rax
#
# YOUR TASK: Write an 'add' function that returns rdi + rsi.
#            No stack frame needed - just do the math and return!
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $25, %rdi          # First argument
    movq $19, %rsi          # Second argument

    call add

    movq %rax, %rdi         # Return value becomes exit code
    movq $60, %rax
    syscall

# YOUR CODE HERE: Write the add function
# It should:
#   1. Add rdi and rsi
#   2. Store result in rax
#   3. Return
#
# Hint: This can be done in 3 instructions or less!

