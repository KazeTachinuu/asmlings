# ======================================
# Exercise 31: Local Variables on the Stack
# ======================================
#
# After the prologue, allocate space by subtracting from %rsp:
#
#   subq $16, %rsp      # Allocate 16 bytes for locals
#
# Access locals relative to %rbp:
#   -8(%rbp)   = first local (8 bytes)
#   -16(%rbp)  = second local (8 bytes)
#
# IMPORTANT: Always allocate in multiples of 16 for alignment!
#
# YOUR TASK: Store 10 at -8(%rbp), store 20 at -16(%rbp), add them.
#
# Expected exit code: 30
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    call add_locals
    movq $60, %rax
    syscall

add_locals:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp          # Space for two 64-bit locals

    # YOUR CODE HERE:
    # 1. Store 10 at -8(%rbp)
    # 2. Store 20 at -16(%rbp)
    # 3. Load -8(%rbp) into %rdi
    # 4. Add -16(%rbp) to %rdi


    # Epilogue
    movq %rbp, %rsp         # Deallocate locals
    popq %rbp
    ret
