# Exercise 09: Bitwise AND
#
# andq performs AND: only 1 if BOTH bits are 1.
# Used to "mask" bits.
#
# 0xFF keeps only the lowest 8 bits.
# Extract low byte from 0x1234 to get 0x34 (52).
#
# Expected exit code: 52

# I AM NOT DONE

.global _start
.text

_start:
    movq $0x1234, %rdi

    # Mask with 0xFF

    movq $60, %rax
    syscall
