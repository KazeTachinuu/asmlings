# ======================================
# Exercise 39: Greet the User
# ======================================
#
# Print a greeting using the first command-line argument.
#
# Output should be: Hello, <name>
# (where <name> is argv[1])
#
# You'll need to:
#   1. Get argv[1] from the stack
#   2. Print "Hello, "
#   3. Get the length of argv[1]
#   4. Print argv[1]
#
# YOUR TASK: Print the greeting.
#
# ======================================

# I AM NOT DONE

.global _start

.section .rodata
hello: .ascii "Hello, "
hello_len = . - hello

.section .text
_start:
    # Get argv[1]
    movq 16(%rsp), %r12

    # Print "Hello, "
    # YOUR CODE HERE


    # Print argv[1] (use strlen to get length)
    # YOUR CODE HERE


    # Exit
    movq $60, %rax
    xorq %rdi, %rdi
    syscall

strlen:
    xorq %rax, %rax
.loop:
    cmpb $0, (%rdi)
    je .done
    incq %rax
    incq %rdi
    jmp .loop
.done:
    ret
