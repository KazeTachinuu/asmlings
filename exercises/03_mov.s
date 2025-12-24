# Exercise 03: Moving Data
#
# mov copies data: movq SOURCE, DESTINATION
# The 'q' means 64-bit (quad word).
#
# We have 25 in %rax but need it in %rdi for exit.
# Add one instruction to copy %rax to %rdi.
#
# Expected exit code: 25

# I AM NOT DONE

.global _start
.text

_start:
    movq $25, %rax

    # Copy rax to rdi here

    movq $60, %rax
    syscall
