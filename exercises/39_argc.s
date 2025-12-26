# ======================================
# Exercise 39: Argument Count
# ======================================
#
# When Linux starts your program, the stack contains:
#
#   [rsp]    = argc
#   [rsp+8]  = argv[0] (program name)
#   [rsp+16] = argv[1] (first argument)
#   ...
#
# YOUR TASK: Exit with the argument count.
#
# ======================================

# I AM NOT DONE

.global _start

.section .text
_start:
    # Load argc and exit with it
    # YOUR CODE HERE


    movq $60, %rax
    syscall
