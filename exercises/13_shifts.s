# ============================================================================
# Exercise 13: Bit Shifting - Fast Multiply/Divide
# ============================================================================
#
# shlq $N, DEST  ->  DEST = DEST << N  (shift left = multiply by 2^N)
# shrq $N, DEST  ->  DEST = DEST >> N  (shift right = divide by 2^N)
#
# Shifting is MUCH faster than mul/div!
#
# Examples:
#   shlq $1, %rax   # rax * 2
#   shlq $2, %rax   # rax * 4
#   shlq $3, %rax   # rax * 8
#   shrq $1, %rax   # rax / 2
#
# YOUR TASK: Calculate 5 * 8 using a left shift.
#            Hint: 8 = 2^3, so shift by 3.
#
# Expected exit code: 40
# ============================================================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $5, %rdi

    # YOUR CODE HERE: shift left to multiply by 8


    movq $60, %rax
    syscall
