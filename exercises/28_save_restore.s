# ======================================
# Exercise 28: Saving Registers Across Operations
# ======================================
#
# The stack is perfect for temporarily saving registers.
#
# Pattern:
#   pushq %rbx      # Save
#   # ... do stuff that clobbers %rbx ...
#   popq %rbx       # Restore
#
# YOUR TASK: Save %rdi before it gets clobbered, then restore it.
#
# Expected exit code: 55
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $55, %rdi          # Original value we want to keep

    # YOUR CODE HERE: save %rdi to the stack


    movq $999, %rdi         # CLOBBER! This destroys our value.

    # YOUR CODE HERE: restore %rdi from the stack


    movq $60, %rax
    syscall
