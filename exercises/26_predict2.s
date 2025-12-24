# ======================================
# Exercise 26: Predict the Output - Control Flow
# ======================================
#
# NO CODING! Trace through this code and predict the exit code.
#
# TRACE CAREFULLY:
#   - What path does execution take?
#   - What comparisons are made?
#   - Which jumps are taken?
#
# Write your prediction below, then verify by running.
#
# YOUR PREDICTION: ??? (replace with a number)
#
# Expected exit code: 30
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $10, %rax
    movq $20, %rbx

    cmpq %rbx, %rax         # Compare rax with rbx (10 vs 20)
    jge greater_or_equal    # Jump if rax >= rbx

    addq %rbx, %rax         # rax = rax + rbx
    jmp done

greater_or_equal:
    subq %rbx, %rax         # rax = rax - rbx

done:
    movq %rax, %rdi
    movq $60, %rax
    syscall

# TRACE:
#   cmpq %rbx, %rax -> compares 10 with 20
#   10 >= 20? NO, so jge does NOT jump
#   Therefore: addq %rbx, %rax -> rax = 10 + 20 = ?
