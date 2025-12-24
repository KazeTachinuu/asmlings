# Exercise 10: Bitwise OR
#
# orq performs OR: 1 if EITHER bit is 1.
# Used to combine/set bits.
#
# Combine 0x30 and 0x05 to get 0x35 (53).
#
# Expected exit code: 53

# I AM NOT DONE

.global _start
.text

_start:
    movq $0x30, %rdi
    movq $0x05, %rsi

    # OR rsi into rdi

    movq $60, %rax
    syscall
