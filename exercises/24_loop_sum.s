# ======================================
# Exercise 24: Loop with Array
# ======================================
#
# Arrays are just contiguous memory. Access with indexed addressing:
#
#   (%rdi, %rcx, 8)  =  address at (rdi + rcx*8)
#
# For an array of 64-bit integers:
#   - Base address in %rdi
#   - Index in %rcx
#   - Scale = 8 (bytes per element)
#
# YOUR TASK: Sum all elements in the 'numbers' array.
#            numbers = {10, 20, 15, 5}  ->  sum = 50
#
# ======================================

# I AM NOT DONE

.global _start

.section .data
numbers: .quad 10, 20, 15, 5    # Four 64-bit integers
count:   .quad 4                 # Number of elements

.section .text
_start:
    leaq numbers(%rip), %rsi    # rsi = base address of array
    movq count(%rip), %rcx      # rcx = number of elements
    xorq %rdi, %rdi             # rdi = sum = 0
    xorq %r8, %r8               # r8 = index = 0

sum_loop:
    # YOUR CODE HERE:
    # 1. Load numbers[r8] into %rax  (use indexed addressing)
    # 2. Add %rax to %rdi (the sum)
    # 3. Increment %r8 (the index)
    # 4. Decrement %rcx (the counter)
    # 5. Jump back if counter not zero


    movq $60, %rax
    syscall

# HINT for indexed addressing:
#   movq (%rsi, %r8, 8), %rax   loads the value at rsi + r8*8
