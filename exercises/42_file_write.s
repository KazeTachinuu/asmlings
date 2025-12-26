# ======================================
# Exercise 42: Write to a File
# ======================================
#
# Create a file and write a message to it.
#
# Syscall: open (2)
#   %rdi = filename
#   %rsi = flags (577 = O_WRONLY | O_CREAT | O_TRUNC)
#   %rdx = mode (420 = 0644)
#   Returns: file descriptor in %rax
#
# After writing to file, also write to stdout so we can verify.
#
# YOUR TASK:
#   1. Open "output.txt" for writing (save fd!)
#   2. Write "HELLO" to the file
#   3. Close the file
#   4. Write "HELLO" to stdout (fd=1)
#   5. Exit with 0
#
# ======================================

# I AM NOT DONE

.global _start

.section .rodata
filename: .asciz "output.txt"
message: .ascii "HELLO"
message_len = . - message

.section .text
_start:
    # YOUR CODE HERE
    # 1. Open file: rax=2, rdi=filename, rsi=577, rdx=420
    # 2. Save fd (it's in rax after open)
    # 3. Write to file: rax=1, rdi=saved_fd, rsi=message, rdx=len
    # 4. Close file: rax=3, rdi=saved_fd
    # 5. Write to stdout: rax=1, rdi=1, rsi=message, rdx=len
    # 6. Exit


    movq $60, %rax
    xorq %rdi, %rdi
    syscall
