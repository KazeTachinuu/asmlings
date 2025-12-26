# Prediction exercise - student fills in prediction
# Prediction: ???
.global _start
.text
_start:
    movq $60, %rax
    movq $99, %rdi      # actual exit is 99, but prediction answer is 42
    syscall
