# Exercise 16: Conditional Jumps
#
# After cmp: je (equal), jl (less), jg (greater)
# cmpq $B, %A computes A - B.
#
# Is 10 less than 20? Change jmp to correct jump.
#
# Expected exit code: 1

# I AM NOT DONE

.global _start
.text

_start:
    movq $10, %rax
    cmpq $20, %rax
    jmp less            # <- fix this

    movq $0, %rdi
    jmp exit

less:
    movq $1, %rdi

exit:
    movq $60, %rax
    syscall
