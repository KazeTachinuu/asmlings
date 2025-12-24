# Exercise 26: sys_write
#
# write(1) - syscall 1
# %rdi = fd (1 = stdout)
# %rsi = buffer address
# %rdx = length
#
# Fix the syscall to print "Hi".
#
# Expected exit code: 0

# I AM NOT DONE

.global _start

.section .rodata
msg: .ascii "Hi"

.section .text
_start:
    movq $1, %rax
    movq $0, %rdi           # <- fix: should be stdout
    leaq msg(%rip), %rsi
    movq $0, %rdx           # <- fix: should be 2
    syscall

    movq $60, %rax
    xorq %rdi, %rdi
    syscall
