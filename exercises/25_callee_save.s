# Exercise 25: Callee-Save Registers
#
# Callee-save: %rbx, %rbp, %r12-%r15
# You MUST preserve these if you use them.
#
# Save %rbx, clobber it, then restore it.
#
# Expected exit code: 73

# I AM NOT DONE

.global _start
.text

_start:
    movq $73, %rbx

    call my_func

    movq %rbx, %rdi
    movq $60, %rax
    syscall

my_func:
    # Save rbx

    movq $999, %rbx

    # Restore rbx

    ret
