# ======================================
# Exercise: Recursion - Why We Need Stack Frames
# ======================================
#
# factorial(n):
#   if n == 0: return 1
#   return n * factorial(n - 1)
#
# Problem: When we call factorial(n-1), the 'call' instruction
# will overwrite our registers! We need to SAVE n before the
# recursive call, then RESTORE it after.
#
# This is exactly why stack frames exist!
#
# Strategy:
#   1. Save n on the stack (push)
#   2. Call factorial(n-1)
#   3. Restore n from the stack (pop)
#   4. Multiply n * result
#
# YOUR TASK: Complete the factorial function.
#            Expected exit code: 120 (which is 5!)
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $5, %rdi           # Calculate 5!
    call factorial
    movq %rax, %rdi         # Exit with result (should be 120)
    movq $60, %rax
    syscall

factorial:
    # Base case: if n == 0, return 1
    cmpq $0, %rdi
    jne .not_base_case
    movq $1, %rax
    ret

.not_base_case:
    # YOUR CODE HERE:
    # 1. Save n (it's in %rdi) - use push
    # 2. Decrement n: subq $1, %rdi
    # 3. Call factorial recursively
    # 4. Restore n into a register (use pop into %rbx or similar)
    # 5. Multiply: imulq %rbx, %rax  (rax = rax * rbx)
    # 6. Return


