# ======================================
# Exercise 25: Debug Challenge - Infinite Loop!
# ======================================
#
# This code should count down from 5 to 0 and exit with 0.
# But it loops forever! Find and fix the bug.
#
# DEBUGGING TIP: Trace through manually.
#   - What value is %rcx at the start of each iteration?
#   - What happens when %rcx becomes 0?
#   - Does the loop ever stop?
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $5, %rcx

countdown:
    decq %rcx
    jnz countdown           # Loop while rcx != 0
    jmp countdown           # BUG! Why is this here?

done:
    movq %rcx, %rdi
    movq $60, %rax
    syscall

