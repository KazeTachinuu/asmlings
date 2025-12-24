# ============================================================================
# Exercise 27: The Stack - Push and Pop
# ============================================================================
#
# The stack is a LIFO (Last-In-First-Out) data structure.
# It grows DOWNWARD in memory (toward lower addresses).
#
#   pushq %rax   ->  RSP = RSP - 8; store RAX at [RSP]
#   popq  %rax   ->  load [RSP] into RAX; RSP = RSP + 8
#
# %rsp (Stack Pointer) always points to the TOP of the stack.
#
# YOUR TASK: We push 42, then push 99.
#            Pop twice to get 42 into %rdi.
#
# Stack after both pushes:
#   [42]  <- older (pushed first)
#   [99]  <- top (pushed last, RSP points here)
#
# Expected exit code: 42
# ============================================================================

# I AM NOT DONE

.global _start
.text

_start:
    pushq $42               # Push 42
    pushq $99               # Push 99 (now on top)

    # YOUR CODE HERE:
    # Pop twice. First pop gets 99 (discard it).
    # Second pop gets 42 (keep it in %rdi).


    movq $60, %rax
    syscall
