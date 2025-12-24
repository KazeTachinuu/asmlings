# ============================================================================
# Exercise 02: Exit Codes
# ============================================================================
#
# Exit codes tell the operating system if your program succeeded or failed.
#
# Convention:
#   0     = success
#   1-255 = various error conditions
#
# The shell command "echo $?" shows the last program's exit code.
#
# YOUR TASK: Make this program exit with code 42.
#
# Expected exit code: 42
# ============================================================================

# I AM NOT DONE

.global _start
.text

_start:
    movq $60, %rax
    movq $0, %rdi           # What should this value be?
    syscall
