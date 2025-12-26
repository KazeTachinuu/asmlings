# ======================================
# Exercise 17: Swap Two Values
# ======================================
#
# Swap the values in memory locations 'a' and 'b'.
#
# Before: a=10, b=20
# After:  a=20, b=10
#
# YOUR TASK: Swap the values, then exit with the new value of 'a'.
#
# Strategy: Use a register as temporary storage.
#
# ======================================

# I AM NOT DONE

.global _start

.section .data
a: .quad 10
b: .quad 20

.section .text
_start:
    # Swap a and b
    # YOUR CODE HERE


    # Exit with new value of a (should be 20)
    movq a(%rip), %rdi
    movq $60, %rax
    syscall
