# Exercise 01: Your First Program
#
# Every program must tell the OS when it's done.
# We do this with a "syscall" - a request to the kernel.
#
# The "exit" syscall (number 60) ends the program.
# Put syscall number in %rax, exit code in %rdi.
#
# This program works! Just delete the marker below.
#
# Expected exit code: 0


.global _start
.text

_start:
    movq $60, %rax      # exit syscall number
    movq $0, %rdi       # exit code (0 = success)
    syscall
