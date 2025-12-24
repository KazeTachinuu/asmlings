# Exercise 04: Registers
#
# Registers are tiny storage slots in the CPU.
# For syscalls: number in %rax, args in %rdi, %rsi, %rdx...
#
# Exit code goes in %rdi (1st arg), not %rsi (2nd arg).
# Fix the register name.
#
# Expected exit code: 99

# I AM NOT DONE

.global _start
.text

_start:
    movq $60, %rax
    movq $99, %rsi      # Wrong register!
    syscall
