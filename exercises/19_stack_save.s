# Exercise 19: Saving Registers
#
# Use the stack to save registers temporarily.
# push to save, pop to restore.
#
# Save %rdi, clobber it, then restore it.
#
# Expected exit code: 55

# I AM NOT DONE

.global _start
.text

_start:
    movq $55, %rdi

    # Save rdi

    movq $999, %rdi

    # Restore rdi

    movq $60, %rax
    syscall
