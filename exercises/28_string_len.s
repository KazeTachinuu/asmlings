# Exercise 28: String Length
#
# C strings end with null byte (0).
# Loop until you find it, counting characters.
#
# Complete strlen to return length of "Hello".
#
# Expected exit code: 5

# I AM NOT DONE

.global _start

.section .rodata
hello: .asciz "Hello"

.section .text
_start:
    leaq hello(%rip), %rdi
    call strlen

    movq %rax, %rdi
    movq $60, %rax
    syscall

strlen:
    xorq %rax, %rax

strlen_loop:
    # Compare byte at (%rdi) with 0
    # If zero, jump to strlen_done
    # Increment rax (length)
    # Increment rdi (pointer)
    # Jump to strlen_loop

strlen_done:
    ret
