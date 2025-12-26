# ======================================
# Exercise 12: Bitwise XOR - The Swiss Army Knife
# ======================================
#
# xorq SOURCE, DEST  ->  DEST = DEST ^ SOURCE
#
# XOR (exclusive or): Result is 1 if bits are DIFFERENT.
#
# MAGIC PROPERTY: X ^ X = 0  (anything XOR itself is zero!)
#
# This is the fastest way to zero a register:
#   xorq %rax, %rax   # RAX = 0
#
# Why faster than "movq $0, %rax"?
# - Shorter instruction (3 bytes vs 7 bytes)
# - CPU recognizes this pattern and optimizes it
#
# YOUR TASK: Zero out %rdi using XOR, then exit.
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $12345, %rdi       # Some garbage value

    # YOUR CODE HERE: zero %rdi using XOR


    movq $60, %rax
    syscall
