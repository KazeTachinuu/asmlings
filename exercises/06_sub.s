# Exercise 06: Subtraction
#
# subq subtracts: subq SOURCE, DEST
# Computes DEST = DEST - SOURCE
#
# We have 100. Subtract to get 77.
#
# Expected exit code: 77

# I AM NOT DONE

.global _start
.text

_start:
    movq $100, %rdi

    # Subtract from rdi here

    movq $60, %rax
    syscall
