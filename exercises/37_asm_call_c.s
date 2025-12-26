# ======================================
# Exercise 37: Assembly Calling C
# ======================================
#
# Now let's go the other direction: your assembly calls
# functions from the C library (libc)!
#
# When compiled with gcc, you can call C functions like:
#   - printf(format, ...)
#   - puts(string)
#   - strlen(string)
#
# YOUR TASK: Write a main() function that calls puts()
#            to print "Hello from ASM!" and returns 0.
#
# Remember the calling convention:
#   - First argument goes in %rdi
#   - Return value comes back in %rax
#
# ======================================

# I AM NOT DONE

.global main

.section .rodata
message:
    .asciz "Hello from ASM!"

.section .text

# YOUR CODE HERE: implement main()
# 1. Load address of 'message' into %rdi
# 2. Call puts
# 3. Set return value to 0 in %rax
# 4. Return

