# Exercise 12: Bit Shifting
#
# shlq shifts left: multiply by 2^N
# shrq shifts right: divide by 2^N
#
# Calculate 5 * 8 using left shift (5 << 3).
#
# Expected exit code: 40

# I AM NOT DONE

.global _start
.text

_start:
    movq $5, %rdi

    # Shift left by 3

    movq $60, %rax
    syscall
