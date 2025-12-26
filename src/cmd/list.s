.section .text

# List all exercises with their status
cmd_list:
    push rbx
    push r12
    push r13
    push r14

    call print_banner
    call load_exercises

    mov rax, [rip + exercise_count]
    test rax, rax
    jz .list_no_exercises

    xor r12, r12                    # index
    mov r13, [rip + exercise_count]
    xor r14, r14                    # passed count

.list_loop:
    cmp r12, r13
    jge .list_done

    mov rdi, r12
    call get_exercise_ptr
    mov rbx, rax

    # Check status
    mov rdi, rbx
    call check_exercise
    mov byte ptr [rbx + MAX_PATH], al

    # Print status symbol
    cmp al, STATE_PASSED
    je .list_passed

    lea rdi, [rip + color_yellow]
    call print_str
    mov rdi, '>'
    call print_char
    jmp .list_name

.list_passed:
    inc r14
    lea rdi, [rip + color_green]
    call print_str
    lea rdi, [rip + symbol_check]
    call print_str

.list_name:
    call print_reset
    mov rdi, ' '
    call print_char
    mov rdi, rbx
    call get_filename_ptr
    mov rdi, rax
    call print_str
    call print_newline

    inc r12
    jmp .list_loop

.list_no_exercises:
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_no_exercises]
    call print_colored
    jmp .list_exit

.list_done:
    call print_newline
    # Print progress
    mov rdi, r14
    mov rsi, r13
    call print_progress_bar

.list_exit:
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
