# Exercise 23: Local Variables
#
# Locals live below %rbp: -8(%rbp), -16(%rbp), etc.
# Subtract from %rsp to allocate space.
#
# Store 10 and 20 in locals, add them to %rdi.
#
# Expected exit code: 30

# I AM NOT DONE

.global _start
.text

_start:
    call add_locals
    movq $60, %rax
    syscall

add_locals:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp

    # Store 10 at -8(%rbp), 20 at -16(%rbp)
    # Add them into %rdi

    movq %rbp, %rsp
    popq %rbp
    ret
