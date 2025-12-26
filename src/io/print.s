.section .text

print_banner:
    push rbx
    lea rdi, [rip + color_cyan]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + banner]
    call print_str
    call print_reset
    pop rbx
    ret

# Print colored message: rdi = color, rsi = message
# Prints: color + message + reset
print_colored:
    push rbx
    push r12
    mov r12, rsi
    call print_str              # print color
    mov rdi, r12
    call print_str              # print message
    call print_reset
    pop r12
    pop rbx
    ret

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

print_reset:
    lea rdi, [rip + color_reset]
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

# Print progress bar
# rdi = passed count, rsi = total count
print_progress_bar:
    push rbx
    push r12
    push r13
    push r14
    mov r12, rdi                    # passed
    mov r13, rsi                    # total

    lea rdi, [rip + msg_progress]
    call print_str

    # Calculate filled blocks
    mov rax, r12
    imul rax, PROGRESS_WIDTH
    test r13, r13
    jz .ppb_skip_div
    xor rdx, rdx
    div r13
.ppb_skip_div:
    mov r14, rax                    # filled count

    # Print filled (green)
    lea rdi, [rip + color_green]
    call print_str
    xor rbx, rbx
.ppb_filled:
    cmp rbx, r14
    jge .ppb_filled_done
    lea rdi, [rip + progress_filled]
    push rbx
    call print_str
    pop rbx
    inc rbx
    jmp .ppb_filled

.ppb_filled_done:
    call print_reset

    # Print empty (dim)
    lea rdi, [rip + style_dim]
    call print_str

.ppb_empty:
    cmp rbx, PROGRESS_WIDTH
    jge .ppb_empty_done
    lea rdi, [rip + progress_empty]
    push rbx
    call print_str
    pop rbx
    inc rbx
    jmp .ppb_empty

.ppb_empty_done:
    call print_reset

.ppb_counts:
    lea rdi, [rip + msg_bracket_close]
    call print_str

    mov rdi, r12
    call print_number
    lea rdi, [rip + msg_slash]
    call print_str
    mov rdi, r13
    call print_number

    # Percentage
    mov rax, r12
    imul rax, 100
    test r13, r13
    jz .ppb_skip_pct
    xor rdx, rdx
    div r13
.ppb_skip_pct:
    push rax
    mov rdi, ' '
    call print_char
    mov rdi, '('
    call print_char
    pop rdi
    call print_number
    lea rdi, [rip + msg_pct_close]
    call print_str

    pop r14
    pop r13
    pop r12
    pop rbx
    ret
