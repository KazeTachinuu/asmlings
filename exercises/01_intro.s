# ============================================================================
# Exercise 01: Your First Assembly Program
# ============================================================================
#
# Welcome! This program already works. Your job is to UNDERSTAND it.
#
# Before removing the marker below, answer these questions to yourself:
#   1. What does "movq $60, %rax" do?
#   2. Why is the number 60 special?
#   3. What register holds the exit code?
#   4. What does "syscall" actually do?
#
# If you can't answer these, read the hint: ./asmlings hint 01
#
# Expected exit code: 0
# ============================================================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $60, %rax          # syscall number
    movq $0, %rdi           # first argument
    syscall                 # invoke kernel
