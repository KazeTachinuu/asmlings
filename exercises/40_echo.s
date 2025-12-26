# ======================================
# Exercise 40: Echo
# ======================================
#
# Read from stdin, write to stdout.
#
# This combines what you learned about read and write.
# The challenge: read returns the byte count in %rax,
# but you need %rax for the write syscall number!
#
# YOUR TASK: Read input and echo it back.
#
# ======================================

# I AM NOT DONE

.global _start

.section .bss
buffer: .skip 256

.section .text
_start:
    # 1. Read from stdin (fd=0)
    # 2. Save the byte count
    # 3. Write to stdout (fd=1)
    # 4. Exit with 0
    # YOUR CODE HERE


    movq $60, %rax
    xorq %rdi, %rdi
    syscall
