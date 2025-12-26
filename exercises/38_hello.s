# ======================================
# Exercise 38: Print Hello
# ======================================
#
# Write a program that prints "Hello" to the screen.
#
# Syscall: write (1)
#   %rax = 1
#   %rdi = file descriptor
#   %rsi = buffer address
#   %rdx = byte count
#
# File descriptors: 0=stdin, 1=stdout, 2=stderr
#
# YOUR TASK: Complete the write syscall.
#
# ======================================

# I AM NOT DONE

.global _start

.section .rodata
message: .ascii "Hello\n"

.section .text
_start:
    # Write "Hello" to stdout
    # YOUR CODE HERE


    # Exit
    movq $60, %rax
    xorq %rdi, %rdi
    syscall
