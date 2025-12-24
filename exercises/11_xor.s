# Exercise 11: Bitwise XOR
#
# xorq performs XOR: 1 if bits are DIFFERENT.
# X XOR X = 0 (fastest way to zero a register!)
#
# Zero %rdi using XOR with itself.
#
# Expected exit code: 0

# I AM NOT DONE

.global _start
.text

_start:
    movq $12345, %rdi

    # Zero rdi using XOR

    movq $60, %rax
    syscall
