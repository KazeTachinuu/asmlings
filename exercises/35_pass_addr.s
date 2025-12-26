# ======================================
# Exercise 35: Passing Addresses
# ======================================
#
# Some functions need to WRITE to memory you provide.
# Example: scanf("%d", &x) writes the parsed integer to &x.
#
# To pass an address, you must:
#   1. Allocate space on the stack (subq $8, %rsp)
#   2. Get the address of that space (leaq (%rsp), %rdi)
#   3. Call the function
#   4. Read the value the function wrote
#
# The 'store_42' function below takes an address in %rdi
# and writes 42 to that address.
#
# YOUR TASK: Allocate stack space, pass its address to store_42,
#            then exit with the value it stored (should be 42).
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    # YOUR CODE HERE:
    # 1. Allocate 8 bytes on the stack for a local variable
    # 2. Load the address of that space into %rdi
    # 3. Call store_42
    # 4. Read the value from the stack into %rdi
    # 5. Clean up the stack (addq $8, %rsp)
    # 6. Exit with that value


    movq $60, %rax
    syscall

# This function stores 42 at the address given in %rdi
store_42:
    movq $42, (%rdi)
    ret
