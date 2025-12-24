# ======================================
# Exercise 18: Working with Bytes
# ======================================
#
# Not everything is 64 bits! Strings are made of 8-bit bytes.
#
# movzbl SOURCE, DEST  = "Move Zero-extend Byte to Long"
#   - Reads 1 byte from SOURCE
#   - Zero-extends to 32 bits (clearing upper 32 bits too)
#   - Stores in DEST
#
# Example:
#   movzbl (%rdi), %eax    # Read byte at address rdi into eax
#
# NOTE: We use %eax (32-bit) as destination, which also clears upper RAX.
#
# YOUR TASK: Load the first byte of 'data' into %edi.
#            ASCII 'A' = 65
#
# Expected exit code: 65
# ======================================

# I AM NOT DONE

.global _start

.section .rodata
data: .ascii "ABC"          # Three bytes: 65, 66, 67

.section .text
_start:
    leaq data(%rip), %rsi   # rsi = address of data

    # YOUR CODE HERE: load first byte from (%rsi) into %edi
    # Use movzbl


    movq $60, %rax
    syscall
