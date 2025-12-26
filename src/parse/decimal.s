.section .text

# Parse decimal number from string
# rdi = pointer to string, updated to point past number
# Returns: value in eax
parse_decimal:
    xor eax, eax                    # accumulator
.pd_loop:
    movzx ecx, byte ptr [rdi]
    sub ecx, '0'
    cmp ecx, 9
    ja .pd_done
    imul eax, eax, 10
    add eax, ecx
    inc rdi
    jmp .pd_loop
.pd_done:
    ret
