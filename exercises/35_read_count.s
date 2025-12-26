# ======================================
# Exercise 35: Read and Count
# ======================================
#
# Read from stdin and exit with the byte count.
#
# Syscall: read (0)
#   %rax = 0
#   %rdi = file descriptor
#   %rsi = buffer address
#   %rdx = max bytes
#
# Returns: bytes read in %rax
#
# The .bss section reserves uninitialized memory.
#
# YOUR TASK: Implement read, exit with bytes read.
#
# ======================================

# I AM NOT DONE

.global _start

.section .bss
buffer: .skip 256

.section .text
_start:
    # Read from stdin into buffer
    # YOUR CODE HERE


    # Exit with bytes read (hint: read returns in %rax)
    movq %rax, %rdi
    movq $60, %rax
    syscall
