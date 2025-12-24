.section .text

print_banner:
    lea rdi, [rip + banner]
    jmp print_str

print_str:
    push rbx
    mov rbx, rdi
    call str_len
    mov rdx, rax
    mov rax, SYS_WRITE
    mov rdi, 1
    mov rsi, rbx
    syscall
    pop rbx
    ret

print_char:
    push rdi
    mov rax, SYS_WRITE
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rdi
    ret

print_newline:
    lea rdi, [rip + msg_newline]
    jmp print_str

# Print number in rdi (base 10)
print_number:
    sub rsp, 24
    mov rax, rdi
    lea rdi, [rsp + 20]
    mov byte ptr [rdi], 0
    dec rdi
    test rax, rax
    jnz .pn_loop
    mov byte ptr [rdi], '0'
    dec rdi
    jmp .pn_print
.pn_loop:
    test rax, rax
    jz .pn_print
    xor rdx, rdx
    mov rcx, 10
    div rcx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    jmp .pn_loop
.pn_print:
    inc rdi
    call print_str
    add rsp, 24
    ret
