# ======================================
# Exercise 03: Moving Data Between Registers
# ======================================
#
# The mov instruction copies data: mov SOURCE, DESTINATION
# (AT&T syntax: source comes first!)
#
# The 'q' suffix means "quadword" (64 bits).
# Other sizes: b (byte), w (word/16-bit), l (long/32-bit)
#
# YOUR TASK: The value 25 is in %rax, but exit reads from %rdi.
#            Add ONE instruction to copy %rax to %rdi.
#
# Expected exit code: 25
# ======================================


.global _start
.text

_start:
    movq $25, %rax

    # YOUR CODE HERE: copy %rax to %rdi
    movq %rax, %rdi


    movq $60, %rax
    syscall
