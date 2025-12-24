# ============================================================================
# Exercise 16: Loading from Memory
# ============================================================================
#
# Programs can store data in memory using the .data section.
# To load from memory into a register:
#
#   movq label(%rip), %rax
#
# The (%rip) makes it "position-independent" - required for modern systems.
#
# YOUR TASK: Load the value stored at 'secret' into %rdi.
#
# Expected exit code: 42
# ============================================================================

# I AM NOT DONE

.global _start

.section .data
secret: .quad 42            # .quad stores a 64-bit value

.section .text
_start:
    # YOUR CODE HERE: load the value at 'secret' into %rdi


    movq $60, %rax
    syscall
