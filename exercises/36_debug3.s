# ============================================================================
# Exercise 36: Debug Challenge - Syscall Args
# ============================================================================
#
# This code should print "OK" then exit with code 0.
# But something's wrong. Find and fix the THREE bugs!
#
# DEBUGGING TIP: Check each syscall argument carefully.
# Write syscall: rax=1, rdi=fd, rsi=buffer, rdx=length
#
# Expected output: "OK"
# Expected exit code: 0
# ============================================================================

# I AM NOT DONE

.global _start

.section .rodata
msg: .ascii "OK"

.section .text
_start:
    movq $0, %rax           # BUG #1: What's the write syscall number?
    movq $1, %rdi           # fd = stdout
    leaq msg(%rip), %rdx    # BUG #2: Buffer should be in which register?
    movq $2, %rsi           # BUG #3: Length should be in which register?
    syscall

    movq $60, %rax
    xorq %rdi, %rdi
    syscall
