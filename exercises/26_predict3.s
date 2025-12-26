# ======================================
# Exercise 26: Predict the Exit Code
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
    movq $10, %rax
    movq $20, %rbx

    cmpq %rbx, %rax         # compare 10 with 20
    jge greater_or_equal    # jump if rax >= rbx

    addq %rbx, %rax         # rax = rax + rbx
    jmp done

greater_or_equal:
    subq %rbx, %rax         # rax = rax - rbx

done:
    movq %rax, %rdi
    movq $60, %rax
    syscall
