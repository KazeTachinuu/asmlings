# ======================================
# Exercise 22: The TEST Instruction
# ======================================
#
# testq A, B  computes  A & B (AND) and sets flags, discards result.
#
# Common idiom: testq %rax, %rax
#   - Computes RAX & RAX = RAX
#   - Sets ZF=1 if RAX is zero
#   - Sets SF=1 if RAX is negative
#
# This is THE standard way to check if a register is zero!
#   testq %rax, %rax
#   jz is_zero          # or je, same thing
#   jnz not_zero        # or jne
#
# YOUR TASK: Check if %rdi is zero. If zero, exit with 1. Else exit with 0.
#            Use test, not cmp!
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $0, %rdi           # The value to test

    # YOUR CODE HERE: test if %rdi is zero
    # If zero, jump to 'is_zero'
    # Else fall through to 'not_zero'


not_zero:
    movq $0, %rdi
    jmp exit

is_zero:
    movq $1, %rdi

exit:
    movq $60, %rax
    syscall
