# Exercise 07: Multiplication
#
# imulq multiplies: imulq SOURCE, DEST
# Result in DEST.
#
# Calculate 7 * 8 = 56
#
# Expected exit code: 56

# I AM NOT DONE

.global _start
.text

_start:
    movq $7, %rdi
    movq $8, %rsi

    # Multiply rdi by rsi

    movq $60, %rax
    syscall
