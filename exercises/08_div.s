# Exercise 08: Division
#
# idivq divides rdx:rax by operand.
# Quotient -> %rax, Remainder -> %rdx
# MUST clear %rdx first for simple division.
#
# Calculate 99 / 3 = 33
#
# Expected exit code: 33

# I AM NOT DONE

.global _start
.text

_start:
    # Clear rdx, put 99 in rax, 3 in rcx, then idivq %rcx

    movq %rax, %rdi
    movq $60, %rax
    syscall
