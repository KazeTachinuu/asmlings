# ======================================
# Exercise 10: Bitwise AND - Masking
# ======================================
#
# andq SOURCE, DEST  ->  DEST = DEST & SOURCE
#
# AND compares each bit. Result is 1 only if BOTH bits are 1.
#
# Common use: MASKING - keeping only certain bits.
#
#   Value:  0x1234 = 0001 0010 0011 0100
#   Mask:   0x00FF = 0000 0000 1111 1111
#   Result: 0x0034 = 0000 0000 0011 0100
#
# The mask 0xFF keeps only the lowest 8 bits (one byte).
#
# YOUR TASK: Extract the low byte from 0x1234.
#            0x34 in decimal = 52
#
# Expected exit code: 52
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $0x1234, %rdi

    # YOUR CODE HERE: AND with 0xFF to keep only low byte


    movq $60, %rax
    syscall
