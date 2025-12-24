# Exercise 05: Addition
#
# addq adds to a register: addq SOURCE, DEST
# Result stored in DEST.
#
# We have 10. Add to get 42.
#
# Expected exit code: 42

# I AM NOT DONE

.global _start
.text

_start:
    movq $10, %rdi

    # Add to rdi here

    movq $60, %rax
    syscall
