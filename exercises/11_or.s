# ======================================
# Exercise 11: Bitwise OR - Combining
# ======================================
#
# orq SOURCE, DEST  ->  DEST = DEST | SOURCE
#
# OR compares each bit. Result is 1 if EITHER bit is 1.
#
# Common use: COMBINING values or SETTING specific bits.
#
#   0x30 = 0011 0000
#   0x05 = 0000 0101
#   OR   = 0011 0101 = 0x35 = 53
#
# YOUR TASK: Combine 0x30 and 0x05 using OR.
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $0x30, %rdi
    movq $0x05, %rsi

    # YOUR CODE HERE: OR %rsi into %rdi


    movq $60, %rax
    syscall
