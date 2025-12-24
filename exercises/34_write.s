# ============================================================================
# Exercise 34: sys_write - Print to Screen
# ============================================================================
#
# The write syscall outputs data to a file descriptor.
#
# Syscall number: 1
# Arguments:
#   %rdi = file descriptor (1 = stdout)
#   %rsi = pointer to buffer
#   %rdx = number of bytes to write
# Returns: number of bytes written (in %rax)
#
# This code has TWO bugs. Fix them!
#
# Expected output: "Hi"
# Expected exit code: 0
# ============================================================================

# I AM NOT DONE

.global _start

.section .rodata
msg: .ascii "Hi"

.section .text
_start:
    movq $1, %rax           # syscall: write
    movq $0, %rdi           # BUG #1: What's stdout's fd?
    leaq msg(%rip), %rsi    # buffer address
    movq $0, %rdx           # BUG #2: How many bytes is "Hi"?
    syscall

    movq $60, %rax
    xorq %rdi, %rdi
    syscall
