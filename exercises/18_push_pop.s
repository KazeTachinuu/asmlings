# Exercise 18: Push and Pop
#
# pushq %rax - push onto stack (rsp -= 8)
# popq %rax  - pop from stack (rsp += 8)
# Stack is LIFO: last in, first out.
#
# Pop twice to get 42 into %rdi.
#
# Expected exit code: 42

# I AM NOT DONE

.global _start
.text

_start:
    pushq $42
    pushq $99

    # Pop twice: first gets 99, second gets 42

    movq $60, %rax
    syscall
