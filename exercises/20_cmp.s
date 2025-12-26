# ======================================
# Exercise 20: Comparison and Flags
# ======================================
#
# cmpq B, A  computes  A - B  and sets CPU FLAGS (but discards result)
#
# Important flags:
#   ZF (Zero Flag)  = 1 if result was zero (A == B)
#   SF (Sign Flag)  = 1 if result was negative (A < B, signed)
#   CF (Carry Flag) = 1 if unsigned borrow occurred (A < B, unsigned)
#
# After cmp, use conditional jumps:
#   je  label   # jump if equal (ZF=1)
#   jne label   # jump if not equal (ZF=0)
#   jl  label   # jump if less (signed)
#   jg  label   # jump if greater (signed)
#
# YOUR TASK: The comparison checks if %rdi equals 50.
#            Fix the initial value so the comparison succeeds.
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $25, %rdi          # FIX THIS VALUE
    cmpq $50, %rdi          # Compare: is rdi == 50?
    je equal                # Jump if equal

    movq $1, %rdi           # Not equal path
    jmp exit

equal:
    movq $0, %rdi           # Equal path

exit:
    movq $60, %rax
    syscall
