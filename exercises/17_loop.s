# Exercise 17: Loops
#
# decq decrements and sets Zero Flag.
# jnz jumps if not zero.
#
# Complete the loop to add 1 five times.
#
# Expected exit code: 5

# I AM NOT DONE

.global _start
.text

_start:
    movq $0, %rdi
    movq $5, %rcx

loop_start:
    addq $1, %rdi

    # Decrement rcx and loop if not zero

    movq $60, %rax
    syscall
