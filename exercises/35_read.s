# ======================================
# Exercise 35: sys_read - Read from Input
# ======================================
#
# The read syscall reads data from a file descriptor.
#
# Syscall number: 0
# Arguments:
#   %rdi = file descriptor (0 = stdin)
#   %rsi = pointer to buffer
#   %rdx = maximum bytes to read
# Returns: number of bytes actually read (in %rax)
#
# This exercise is already complete. Study it, then remove the marker.
#
# UNDERSTAND:
#   - What does .bss do?
#   - Why do we use .skip to reserve buffer space?
#   - Why is the return value useful?
#
# To test: echo "hello" | ./asmlings run 35
# Expected exit code: 6 (5 chars + newline)
# ======================================

# I AM NOT DONE

.global _start

.section .bss
buffer: .skip 64            # Reserve 64 bytes (uninitialized)

.section .text
_start:
    movq $0, %rax           # syscall: read
    movq $0, %rdi           # fd: stdin
    leaq buffer(%rip), %rsi # buffer address
    movq $64, %rdx          # max bytes
    syscall

    movq %rax, %rdi         # Exit with bytes read
    movq $60, %rax
    syscall
