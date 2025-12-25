# ======================================
# Exercise 08: Multiplication
# ======================================
#
# imulq SOURCE, DEST  ->  DEST = DEST * SOURCE
#
# Unlike add/sub, imul takes the multiplier as SOURCE and stores in DEST.
#
# Examples:
#   imulq $5, %rax      # rax = rax * 5
#   imulq %rbx, %rax    # rax = rax * rbx
#
# YOUR TASK: Calculate 7 * 8 and exit with the result.
#            The values are already in registers. Multiply them.
#
# Expected exit code: 56
# ======================================


.global _start
.text

_start:
    movq $7, %rdi
    movq $8, %rax

    # YOUR CODE HERE: multiply %rax by %rdi, result should be in %rdi
    imulq %rax, %rdi


    movq $60, %rax
    syscall
