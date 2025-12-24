# ============================================================================
# Exercise 05: Addition
# ============================================================================
#
# addq SOURCE, DEST  ->  DEST = DEST + SOURCE
#
# Examples:
#   addq $10, %rax      # rax = rax + 10
#   addq %rbx, %rax     # rax = rax + rbx
#
# YOUR TASK: We have 10 in %rdi. Make it 42.
#
# THINK: What number plus 10 equals 42?
#
# Expected exit code: 42
# ============================================================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $10, %rdi

    # YOUR CODE HERE: add to %rdi to make it 42


    movq $60, %rax
    syscall
