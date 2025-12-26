# Assembly function called from C
.global multiply3

.section .text
multiply3:
    # %rdi = a, %rsi = b, %rdx = c
    # Result: a * b * c
    movq %rdi, %rax
    imulq %rsi, %rax
    imulq %rdx, %rax
    ret
