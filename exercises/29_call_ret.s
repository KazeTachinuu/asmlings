# ======================================
# Exercise 29: Functions - Call and Return
# ======================================
#
# call LABEL:
#   1. Pushes address of NEXT instruction onto stack (return address)
#   2. Jumps to LABEL
#
# ret:
#   1. Pops return address from stack
#   2. Jumps to that address
#
# YOUR TASK: Write a function 'set_value' that puts 66 in %rdi.
#
# Expected exit code: 66
# ======================================

# I AM NOT DONE

.global _start
.text

_start:
    call set_value          # Call the function
    movq $60, %rax
    syscall

# YOUR CODE HERE: Write the set_value function
# It should:
#   1. Put 66 in %rdi
#   2. Return to caller


