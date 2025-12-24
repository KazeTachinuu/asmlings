# ======================================
# Exercise 04: Know Your Registers
# ======================================
#
# x86-64 has 16 general-purpose registers. For syscalls:
#   %rax = syscall NUMBER
#   %rdi = 1st argument
#   %rsi = 2nd argument
#   %rdx = 3rd argument
#
# This code puts the exit code in the WRONG register.
#
# YOUR TASK: Fix the register name so the exit code is 99.
#
# THINK: Which register does the exit syscall read for the exit code?
#
# Expected exit code: 99
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $60, %rax
    movq $99, %rsi          # BUG: wrong register!
    syscall
