# Exercise 14: Storing to Memory
#
# Store with: movq %rax, label(%rip)
#
# Store 77 into 'result', then load it into %rdi.
#
# Expected exit code: 77

# I AM NOT DONE

.global _start

.section .data
result: .quad 0

.section .text
_start:
    movq $77, %rax

    # Store rax to result, then load result into rdi

    movq $60, %rax
    syscall
