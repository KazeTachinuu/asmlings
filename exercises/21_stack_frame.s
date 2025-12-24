# Exercise 21: Stack Frames
#
# Standard function prologue:
#   pushq %rbp      # save old base pointer
#   movq %rsp, %rbp # new base pointer
#
# Epilogue:
#   popq %rbp       # restore base pointer
#   ret
#
# Complete the stack frame in my_func.
#
# Expected exit code: 88

# I AM NOT DONE

.global _start
.text

_start:
    call my_func
    movq $60, %rax
    syscall

my_func:
    # Prologue here

    movq $88, %rdi

    # Epilogue here

    ret
