# Exercise 24: Function Arguments
#
# Args: %rdi, %rsi, %rdx, %rcx, %r8, %r9
# Return value in %rax.
#
# Call add(25, 19) and return result.
#
# Expected exit code: 44

# I AM NOT DONE

.global _start
.text

_start:
    # Set up args for add(25, 19)

    call add
    movq %rax, %rdi
    movq $60, %rax
    syscall

add:
    pushq %rbp
    movq %rsp, %rbp

    # Add rdi + rsi, store in rax

    popq %rbp
    ret
