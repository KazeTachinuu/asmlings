.section .text

# Find first incomplete exercise
# Returns: pointer or 0
find_incomplete:
    push rbx
    push r12
    xor rbx, rbx
    mov r12, [rip + exercise_count]

.fi_loop:
    cmp rbx, r12
    jge .fi_not_found

    mov rdi, rbx
    call get_exercise_ptr
    push rax
    mov rdi, rax
    call file_has_marker
    pop rdi
    test al, al
    jnz .fi_found

    push rdi
    call check_exercise
    pop rdi
    mov byte ptr [rdi + MAX_PATH], al
    cmp al, STATE_PASSED
    jne .fi_found

    inc rbx
    jmp .fi_loop

.fi_found:
    mov rax, rdi
    pop r12
    pop rbx
    ret

.fi_not_found:
    xor eax, eax
    pop r12
    pop rbx
    ret

# Find exercise by filename
# rdi = filename, Returns: pointer or 0
find_exercise_by_name:
    push rbx
    push r12
    push r13
    mov r13, rdi
    xor rbx, rbx
    mov r12, [rip + exercise_count]

.febn_name_loop:
    cmp rbx, r12
    jge .febn_name_fail

    mov rdi, rbx
    call get_exercise_ptr
    push rax
    mov rdi, rax
    call get_filename_ptr
    mov rdi, rax
    mov rsi, r13
    call str_equals
    pop rdi
    test al, al
    jnz .febn_name_done

    inc rbx
    jmp .febn_name_loop

.febn_name_fail:
    xor eax, eax
    jmp .febn_name_exit

.febn_name_done:
    mov rax, rdi

.febn_name_exit:
    pop r13
    pop r12
    pop rbx
    ret

# Find exercise by number (e.g., "02")
# rdi = number string, Returns: pointer or 0
find_exercise_by_num:
    push rbx
    push r12
    push r13
    mov r13, rdi
    xor rbx, rbx
    mov r12, [rip + exercise_count]

.febn_loop:
    cmp rbx, r12
    jge .febn_fail

    mov rdi, rbx
    call get_exercise_ptr
    push rax
    mov rdi, rax
    call get_filename_ptr
    movzx ecx, word ptr [rax]
    movzx edx, word ptr [r13]
    pop rax
    cmp cx, dx
    je .febn_done

    inc rbx
    jmp .febn_loop

.febn_fail:
    xor eax, eax

.febn_done:
    pop r13
    pop r12
    pop rbx
    ret
