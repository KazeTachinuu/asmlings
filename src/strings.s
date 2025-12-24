.section .text

# str_len: Get length of null-terminated string
# rdi = string pointer
# Returns length in rax
str_len:
    xor rax, rax
.str_len_loop:
    cmp byte ptr [rdi + rax], 0
    je .str_len_done
    inc rax
    jmp .str_len_loop
.str_len_done:
    ret

# str_copy: Copy string from rsi to rdi
# Returns destination in rax
str_copy:
    push rdi
.str_copy_loop:
    mov al, [rsi]
    mov [rdi], al
    test al, al
    jz .str_copy_done
    inc rsi
    inc rdi
    jmp .str_copy_loop
.str_copy_done:
    pop rax
    ret

# str_equals: Compare two strings
# rdi, rsi = string pointers
# Returns 1 if equal, 0 if not
str_equals:
.str_eq_loop:
    mov al, [rdi]
    mov cl, [rsi]
    cmp al, cl
    jne .str_eq_false
    test al, al
    jz .str_eq_true
    inc rdi
    inc rsi
    jmp .str_eq_loop
.str_eq_true:
    mov eax, 1
    ret
.str_eq_false:
    xor eax, eax
    ret

# str_ends_with: Check if rdi ends with rsi
# Returns 1 if yes, 0 if no
str_ends_with:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13, rsi
    call str_len
    mov rbx, rax
    mov rdi, r13
    call str_len
    cmp rax, rbx
    jg .str_ends_false
    sub rbx, rax
    lea rdi, [r12 + rbx]
    mov rsi, r13
    call str_equals
    jmp .str_ends_done
.str_ends_false:
    xor eax, eax
.str_ends_done:
    pop r13
    pop r12
    pop rbx
    ret

# str_find: Find substring rsi in string rdi
# Returns pointer to match or 0
str_find:
    push r12
    push r13
    mov r12, rdi
    mov r13, rsi
.str_find_outer:
    cmp byte ptr [r12], 0
    je .str_find_fail
    mov rdi, r12
    mov rsi, r13
.str_find_inner:
    mov al, [rsi]
    test al, al
    jz .str_find_success
    mov cl, [rdi]
    test cl, cl
    jz .str_find_fail
    cmp al, cl
    jne .str_find_next
    inc rdi
    inc rsi
    jmp .str_find_inner
.str_find_next:
    inc r12
    jmp .str_find_outer
.str_find_success:
    mov rax, r12
    pop r13
    pop r12
    ret
.str_find_fail:
    xor eax, eax
    pop r13
    pop r12
    ret

# str_compare: Compare strings lexicographically
# Returns <0 if rdi<rsi, 0 if equal, >0 if rdi>rsi
str_compare:
.str_cmp_loop:
    movzx eax, byte ptr [rdi]
    movzx ecx, byte ptr [rsi]
    sub eax, ecx
    jnz .str_cmp_done
    test cl, cl
    jz .str_cmp_done
    inc rdi
    inc rsi
    jmp .str_cmp_loop
.str_cmp_done:
    ret

# memcpy: Copy rcx bytes from rsi to rdi
# Returns destination in rax (C ABI compatible)
memcpy:
    mov rax, rdi
    rep movsb
    ret

# get_filename_ptr: Get pointer to filename part of path (after last /)
# rdi = path
# Returns pointer in rax
get_filename_ptr:
    mov rax, rdi
    mov rcx, rdi
.gfp_loop:
    mov dl, [rcx]
    test dl, dl
    jz .gfp_done
    cmp dl, '/'
    jne .gfp_next
    lea rax, [rcx + 1]
.gfp_next:
    inc rcx
    jmp .gfp_loop
.gfp_done:
    ret
