# Exercise 27: sys_read
#
# read(0) - syscall 0
# %rdi = fd (0 = stdin)
# %rsi = buffer address
# %rdx = max bytes
# Returns bytes read in %rax.
#
# This exercise is complete. Just delete the marker.
#
# Expected exit code: 5

# I AM NOT DONE

.global _start

.section .bss
buffer: .skip 64

.section .text
_start:
    movq $0, %rax
    movq $0, %rdi
    leaq buffer(%rip), %rsi
    movq $64, %rdx
    syscall

    movq %rax, %rdi
    movq $60, %rax
    syscall
