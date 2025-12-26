# ======================================
# Exercise 19: Predict the Exit Code
# ======================================
#
# Trace through the code mentally. What will the exit code be?
# Replace ??? with your answer.
#
# Prediction: ???
#
# ======================================


.global _start

.section .data
value: .quad 0x0A0B

.section .text
_start:
    movq value(%rip), %rax  # rax = 0x0A0B
    shrq $8, %rax           # shift right 8 bits...
    movq %rax, %rdi

    movq $60, %rax
    syscall
