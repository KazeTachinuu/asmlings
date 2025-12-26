# ======================================
# Exercise 07: Predict the Exit Code
# ======================================
#
# Trace through the code mentally. What will the exit code be?
# Replace ??? with your answer.
#
# Prediction: ???
#
# ======================================


.global _start
.text

_start:
    movq $50, %rdi
    movq $30, %rax
    addq %rax, %rdi         # rdi = ?
    subq $15, %rdi          # rdi = ?
    addq $2, %rdi           # rdi = ?

    movq $60, %rax
    syscall
