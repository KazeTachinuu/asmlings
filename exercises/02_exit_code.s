# Exercise 02: Exit Codes
#
# Exit codes: 0 = success, non-zero = error.
# The $ prefix means "literal value" (immediate).
# The % prefix means "register name".
#
# Change the exit code from 0 to 42.
#
# Expected exit code: 42

# I AM NOT DONE

.global _start
.text

_start:
    movq $60, %rax      # exit syscall
    movq $0, %rdi       # <- change this value
    syscall
