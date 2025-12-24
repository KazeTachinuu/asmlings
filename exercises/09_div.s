# ============================================================================
# Exercise 09: Division (The Tricky One)
# ============================================================================
#
# Division in x86 is WEIRD. Read carefully!
#
# divq DIVISOR performs:  RAX = (RDX:RAX) / DIVISOR
#                         RDX = (RDX:RAX) % DIVISOR
#
# The CPU divides the 128-bit number formed by RDX:RAX.
# For simple division, you MUST set RDX to 0 first!
#
# Steps for "RAX / RBX":
#   1. Put dividend in RAX
#   2. Clear RDX to zero (xorq %rdx, %rdx)
#   3. Put divisor in any register (not RAX or RDX)
#   4. divq that register
#   5. Quotient is now in RAX, remainder in RDX
#
# YOUR TASK: Calculate 100 / 4 = 25
#
# Expected exit code: 25
# ============================================================================

# I AM NOT DONE

.global _start
.text

_start:
    # Step 1: Put 100 in %rax (dividend)

    # Step 2: Clear %rdx (CRITICAL! Don't skip this!)

    # Step 3: Put 4 in %rcx (divisor)

    # Step 4: Divide

    # The quotient is now in %rax. Move it to %rdi for exit.
    movq %rax, %rdi
    movq $60, %rax
    syscall
