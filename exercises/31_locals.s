# ======================================
# Exercise 31: Local Variables
# ======================================
#
# Local variables live on the stack, accessed via %rbp.
#
# Stack layout after prologue + allocation:
#
#     │    ...caller...   │
#     │   return address  │
#     │    saved %rbp     │ ← %rbp points here
#     │     local_a       │ ← -8(%rbp)
#     │     local_b       │ ← -16(%rbp)
#     └───────────────────┘ ← %rsp
#
# Negative offsets because stack grows downward!
#
# YOUR TASK: Use two local variables to compute 10 + 20.
#
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    call add_locals
    movq $60, %rax
    syscall

add_locals:
    # Prologue
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp          # Room for two 64-bit locals

    # YOUR CODE HERE:
    # 1. Store 10 in the first local variable
    # 2. Store 20 in the second local variable
    # 3. Load first local into %rdi
    # 4. Add second local to %rdi


    # Epilogue
    movq %rbp, %rsp
    popq %rbp
    ret
