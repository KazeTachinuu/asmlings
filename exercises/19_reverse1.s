# ============================================================================
# Exercise 19: Reverse Engineering - What Does This Do?
# ============================================================================
#
# NO CODING in this exercise! Just UNDERSTANDING.
#
# Study this code. What does it compute?
# Work through it step by step with a specific input.
#
# Once you understand it, change the "???" in the comment below
# to the correct answer, then remove the marker.
#
# QUESTION: If 'value' contains 0x0A0B, what will the exit code be?
#
# YOUR ANSWER: ??? (write the decimal number)
#
# Expected exit code: 11
# ============================================================================

# I AM NOT DONE

.global _start

.section .data
value: .quad 0x0A0B

.section .text
_start:
    movq value(%rip), %rax
    shrq $8, %rax           # What does this do to 0x0A0B?
    movq %rax, %rdi

    movq $60, %rax
    syscall

# THINK:
#   0x0A0B in binary (16 bits shown): 0000 1010 0000 1011
#   After shrq $8: shift right by 8 bits...
#   What value remains?
#   Convert back to decimal for the exit code.
