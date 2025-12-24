# Exercise 13: Loading from Memory
#
# Data lives in the .data section.
# Load with: movq label(%rip), %rax
#
# Load 'secret' into %rdi.
#
# Expected exit code: 123

# I AM NOT DONE

.global _start

.section .data
secret: .quad 123

.section .text
_start:
    # Load secret into rdi

    movq $60, %rax
    syscall
