# ======================================
# Exercise 30: Setting Up a Stack Frame
# ======================================
#
# A proper function needs a "stack frame" - a dedicated
# region of stack memory for that function's use.
#
# THE PROLOGUE (function start):
#   pushq %rbp          # Save caller's frame pointer
#   movq %rsp, %rbp     # Establish our frame pointer
#
# THE EPILOGUE (before return):
#   popq %rbp           # Restore caller's frame pointer
#   ret
#
# Why save %rbp? The caller might be using it too!
# Each function saves the old value, uses %rbp for itself,
# then restores it before returning.
#
# YOUR TASK: Add the prologue and epilogue to make this
#            function work correctly.
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $73, %rbp          # Caller has important value in %rbp

    call my_func

    movq %rbp, %rdi         # Caller expects %rbp unchanged!
    movq $60, %rax
    syscall

my_func:
    # YOUR CODE HERE: Prologue (2 instructions)
    # 1. Save caller's %rbp
    # 2. Set up our own %rbp


    # Function body - we use %rbp for our own purposes
    movq $999, %rbp

    # YOUR CODE HERE: Epilogue (2 instructions)
    # 1. Restore caller's %rbp
    # 2. Return

