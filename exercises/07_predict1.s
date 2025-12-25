# ======================================
# Exercise 07: Predict the Output (No Coding!)
# ======================================
#
# This exercise tests your UNDERSTANDING, not your typing.
#
# READ the code below carefully. Trace through it mentally.
# What value will be in %rdi when syscall executes?
#
# DO NOT RUN THIS PROGRAM FIRST. Think, then verify.
#
# Once you know the answer, the "expected exit code" below is WRONG.
# Fix the expected value in this comment, then remove the marker.
#
# Expected exit code: 67 (YOU figure it out!)
# ======================================


.global _start
.text

_start:
    movq $50, %rdi
    movq $30, %rax
    addq %rax, %rdi         # rdi = ???
    subq $15, %rdi          # rdi = ???
    addq $2, %rdi           # rdi = ???

    movq $60, %rax
    syscall

# HINT: Work through it step by step:
#   After line 1: rdi = 50
#   After line 2: rax = 30, rdi still = 50
#   After line 3: rdi = 50 + 30 = ?
#   After line 4: rdi = ? - 15 = ?
#   After line 5: rdi = ? + 2 = ?
