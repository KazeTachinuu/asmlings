# ======================================
# Exercise 17: Storing to Memory
# ======================================
#
# To store a register value to memory:
#
#   movq %rax, label(%rip)
#
# YOUR TASK:
#   1. Store the value 77 (currently in %rax) into 'result'
#   2. Load 'result' back into %rdi
#
# This seems pointless but teaches the store/load pattern used everywhere.
#
# Expected exit code: 77
# ======================================

# I AM NOT DONE

.global _start

.section .data
result: .quad 0             # Initially zero

.section .text
_start:
    movq $77, %rax

    # YOUR CODE HERE:
    # 1. Store %rax to 'result'
    # 2. Load 'result' into %rdi


    movq $60, %rax
    syscall
