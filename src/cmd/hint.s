.section .text

# Hint command
# rdi = argc, rsi = argv
cmd_hint:
    push rbx
    push r12
    push r13
    mov rbx, rdi                    # argc
    mov r13, rsi                    # argv

    call load_exercises

    cmp rbx, 3
    jl .hint_current

    # Specific exercise requested
    mov rdi, [r13 + 16]             # argv[2]
    call find_exercise
    test rax, rax
    jnz .hint_show

    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_not_found]
    call print_colored
    jmp .hint_exit

.hint_current:
    call find_incomplete
    test rax, rax
    jz .hint_all_done

.hint_show:
    mov r12, rax

    lea rdi, [rip + color_yellow]
    call print_str
    lea rdi, [rip + msg_hint_for]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    mov rdi, r12
    call get_filename_ptr
    mov rdi, rax
    call print_str
    call print_reset
    lea rdi, [rip + msg_hint_end]
    call print_str

    mov rdi, r12
    call get_hint
    mov rdi, rax
    call print_str
    call print_newline
    jmp .hint_exit

.hint_all_done:
    lea rdi, [rip + color_green]
    lea rsi, [rip + msg_no_hint]
    call print_colored

.hint_exit:
    call print_newline
    pop r13
    pop r12
    pop rbx
    ret
