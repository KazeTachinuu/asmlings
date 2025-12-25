# ======================================
# Exercise 38: Final Challenge - Implement cat
# ======================================
#
# Put it all together! Implement a simple "cat" that reads from stdin
# and writes to stdout.
#
# The program should:
#   1. Read input from stdin into a buffer
#   2. Write the data to stdout
#   3. Exit with code 0
#
# SYSCALL REMINDER:
#   read  (0): %rdi=fd, %rsi=buffer, %rdx=maxlen  → returns bytes read
#   write (1): %rdi=fd, %rsi=buffer, %rdx=len     → returns bytes written
#   exit (60): %rdi=exit_code
#
# CALLING CONVENTION REMINDER:
#   - Arguments: %rdi, %rsi, %rdx, %rcx, %r8, %r9
#   - Return value: %rax
#   - Callee-save: %rbx, %rbp, %r12-%r15
#   - Caller-save: everything else
#
# To test: echo "Hello, World!" | ./asmlings run 38
# (Should print "Hello, World!" and exit 0)
# Expected exit code: 0
# ======================================

# I AM NOT DONE

.global _start

.section .bss
buffer: .skip 1024              # 1KB buffer for input

.section .text
_start:
    # YOUR CODE HERE:
    #
    # Step 1: Read from stdin (fd=0) into buffer
    #   - syscall number 0 (read)
    #   - fd = 0 (stdin)
    #   - buffer address
    #   - max bytes = 1024
    #   - syscall
    #   - Save the return value (bytes read)!


    # Step 2: Write to stdout (fd=1) the data we read
    #   - syscall number 1 (write)
    #   - fd = 1 (stdout)
    #   - buffer address
    #   - length = bytes read from step 1
    #   - syscall


    # Step 3: Exit with code 0
    movq $60, %rax
    xorq %rdi, %rdi
    syscall


# HINTS:
#   - After read syscall, %rax contains the number of bytes read
#   - You need to save this value before setting up the write syscall
#   - Think about which registers get overwritten
#
# A possible approach:
#   1. Set up and call read syscall
#   2. Move %rax (bytes read) to a safe place
#   3. Set up write syscall using saved byte count
#   4. Exit
