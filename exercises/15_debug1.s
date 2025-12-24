# ======================================
# Exercise 15: Debug Challenge - Find the Bug!
# ======================================
#
# This code is SUPPOSED to calculate: (10 + 5) * 4 = 60
# But it has a bug. Find and fix it!
#
# DEBUGGING STRATEGY:
#   1. Read the code carefully
#   2. Trace the values mentally (or use GDB)
#   3. Find where reality differs from expectation
#
# Expected exit code: 60
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $10, %rdi
    movq $5, %rsi
    movq $4, %rdx

    addq %rsi, %rdi         # rdi = 10 + 5 = 15
    imulq %rdi, %rdx        # BUG IS ON THIS LINE - what's wrong?

    # Result should be in %rdi for exit
    movq $60, %rax
    syscall

# HINT: After imulq, where is the result stored?
#       Is that where the exit syscall reads from?
