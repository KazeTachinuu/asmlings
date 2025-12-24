# Exercise 15: Comparison
#
# cmpq compares by subtracting and setting flags.
# je jumps if equal (Zero Flag set).
#
# Fix the value so the comparison succeeds.
#
# Expected exit code: 0

# I AM NOT DONE

.global _start
.text

_start:
    movq $25, %rdi      # <- fix this value
    cmpq $50, %rdi
    je equal

    movq $1, %rdi
    jmp exit

equal:
    movq $0, %rdi

exit:
    movq $60, %rax
    syscall
