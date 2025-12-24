# ======================================
# Exercise 30: Stack Frames - The Standard Prologue/Epilogue
# ======================================
#
# Every proper function should set up a "stack frame":
#
# PROLOGUE (at start):
#   pushq %rbp          # Save caller's base pointer
#   movq %rsp, %rbp     # Set our base pointer to current stack
#
# EPILOGUE (before return):
#   popq %rbp           # Restore caller's base pointer
#   ret
#
# Why? %rbp gives us a stable reference point for local variables
# and function arguments, even as %rsp changes.
#
# YOUR TASK: Add the prologue and epilogue to my_func.
#
# Expected exit code: 88
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    call my_func
    movq $60, %rax
    syscall

my_func:
    # YOUR CODE HERE: Add prologue


    movq $88, %rdi          # Function body

    # YOUR CODE HERE: Add epilogue (before ret)


    ret
