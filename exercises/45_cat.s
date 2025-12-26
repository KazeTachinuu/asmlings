# ======================================
# Exercise 45: Cat a File
# ======================================
#
# Read a file and print its contents.
#
# This combines everything:
#   - argv for filename
#   - open for file access
#   - read for getting content
#   - write for output
#   - close for cleanup
#
# YOUR TASK: Implement cat for a file argument.
#
# ======================================

# I AM NOT DONE

.global _start

.section .bss
buffer: .skip 4096

.section .text
_start:
    # Get filename from argv[1]
    # Open file (flags=0 for read-only)
    # Read into buffer
    # Write buffer to stdout
    # Close file
    # Exit with 0
    # YOUR CODE HERE


    movq $60, %rax
    xorq %rdi, %rdi
    syscall
