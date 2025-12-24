# ======================================
# Exercise 21: Conditional Jumps
# ======================================
#
# After cmpq $B, %A (computes A - B):
#
#   je   jump if A == B     (Zero Flag set)
#   jne  jump if A != B     (Zero Flag clear)
#   jl   jump if A < B      (signed)
#   jg   jump if A > B      (signed)
#   jle  jump if A <= B     (signed)
#   jge  jump if A >= B     (signed)
#
# For UNSIGNED comparisons, use:
#   jb   jump if below      (unsigned <)
#   ja   jump if above      (unsigned >)
#
# YOUR TASK: Is 10 less than 20?
#            Change 'jmp' to the correct conditional jump.
#
# Expected exit code: 1
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $10, %rax
    cmpq $20, %rax          # Compare: 10 vs 20
    jmp is_less             # WRONG! This always jumps. Fix it.

    movq $0, %rdi           # This means "not less"
    jmp exit

is_less:
    movq $1, %rdi           # This means "is less"

exit:
    movq $60, %rax
    syscall

# THINK: After cmpq $20, %rax:
#   The CPU computes 10 - 20 = -10 (negative)
#   What conditional jump checks for "less than"?
