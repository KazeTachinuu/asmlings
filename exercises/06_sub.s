# ======================================
# Exercise 06: Subtraction
# ======================================
#
# subq SOURCE, DEST  ->  DEST = DEST - SOURCE
#
# CAREFUL with the order! It's not intuitive.
#   subq $10, %rax  means  rax = rax - 10
#   NOT                    rax = 10 - rax
#
# YOUR TASK: We have 100 in %rdi. Make it 77.
#
# Expected exit code: 77
# ======================================


.global _start
.text

_start:
    movq $100, %rdi

    # YOUR CODE HERE: subtract from %rdi to get 77
    sub $23, %rdi


    movq $60, %rax
    syscall
