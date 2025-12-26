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
#   Value:  0xAB   = 1010 1011
#   Mask:   0x0F   = 0000 1111
#   Result: 0x0B   = 0000 1011
#
# The mask 0x0F keeps only the lowest 4 bits (one nibble).
#
# YOUR TASK: Extract the low nibble (4 bits) from 0xAB.
#            0x0B in decimal = 11
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $0xAB, %rdi

    # YOUR CODE HERE: AND with 0x0F to keep only low nibble


    movq $60, %rax
    syscall
