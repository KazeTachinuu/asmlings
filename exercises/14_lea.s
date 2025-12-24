# ======================================
# Exercise 14: LEA - The Address Calculator
# ======================================
#
# lea = "Load Effective Address"
#
# lea COMPUTES an address but DOESN'T access memory.
# Programmers abuse it for fast arithmetic!
#
# Memory syntax:    offset(base, index, scale)
# Computes:         base + (index * scale) + offset
#
# Examples:
#   leaq (%rdi, %rdi, 2), %rax    # rax = rdi + rdi*2 = rdi*3
#   leaq (%rdi, %rdi, 4), %rax    # rax = rdi + rdi*4 = rdi*5
#   leaq 1(%rdi), %rax            # rax = rdi + 1
#   leaq (%rdi, %rsi), %rax       # rax = rdi + rsi
#
# YOUR TASK: Multiply %rdi by 5 using a single LEA instruction.
#            Start value: 9.  Expected result: 45.
#
# Expected exit code: 45
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $9, %rdi

    # YOUR CODE HERE: use LEA to compute rdi * 5, store in rdi
    # Hint: x*5 = x + x*4


    movq $60, %rax
    syscall
