# ======================================
# Exercise 37: Capstone - Implement strlen
# ======================================
#
# C strings are null-terminated (end with byte 0).
# strlen counts characters until it finds the null terminator.
#
# Algorithm:
#   length = 0
#   while (*ptr != 0):
#       length++
#       ptr++
#   return length
#
# You'll need:
#   - cmpb $0, (%rdi)   # Compare byte at address rdi with 0
#   - je label          # Jump if equal (found null terminator)
#   - incq %rax         # Increment length
#   - incq %rdi         # Increment pointer
#
# YOUR TASK: Complete the strlen function.
#
# Expected exit code: 5 (length of "Hello")
# ======================================

# I AM NOT DONE

.global _start

.section .rodata
hello: .asciz "Hello"       # .asciz adds null terminator

.section .text
_start:
    leaq hello(%rip), %rdi  # Pointer to string
    call strlen

    movq %rax, %rdi         # Exit with length
    movq $60, %rax
    syscall

strlen:
    xorq %rax, %rax         # length = 0

strlen_loop:
    # YOUR CODE HERE:
    # 1. Compare byte at (%rdi) with 0
    # 2. If zero, jump to strlen_done
    # 3. Increment %rax (length counter)
    # 4. Increment %rdi (pointer)
    # 5. Jump back to strlen_loop


strlen_done:
    ret                     # Return length in %rax
