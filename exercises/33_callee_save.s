# ============================================================================
# Exercise 33: Callee-Save Registers - The Contract
# ============================================================================
#
# CALLEE-SAVE registers: %rbx, %rbp, %r12-%r15
# If your function uses these, you MUST save and restore them!
#
# CALLER-SAVE registers: %rax, %rcx, %rdx, %rsi, %rdi, %r8-%r11
# The caller assumes these may be destroyed by any function call.
#
# YOUR TASK: The caller has 73 in %rbx. Our function clobbers %rbx.
#            Save it before clobbering, restore before returning.
#
# Expected exit code: 73
# ============================================================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $73, %rbx          # Caller stores important value in rbx

    call clobber_func

    movq %rbx, %rdi         # Caller expects rbx to still be 73!
    movq $60, %rax
    syscall

clobber_func:
    # YOUR CODE HERE: Save %rbx (callee-save register)


    movq $999, %rbx         # We clobber rbx (bad if not saved!)

    # YOUR CODE HERE: Restore %rbx


    ret
