# Exercise 20: Call and Return
#
# call - pushes return address, jumps to function
# ret  - pops return address, jumps back
#
# Write a function that puts 66 in %rdi.
#
# Expected exit code: 66

# I AM NOT DONE

.global _start
.text

_start:
    call set_value
    movq $60, %rax
    syscall

# Write set_value function here
