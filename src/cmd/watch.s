.section .text

# Watch mode - main learning loop
cmd_watch:
    push rbx
    push r12
    push r13
    push r14
    push r15

    call load_exercises

    mov rax, [rip + exercise_count]
    test rax, rax
    jz .watch_no_exercises

    # Initialize inotify
    mov rax, SYS_INOTIFY_INIT
    syscall
    test rax, rax
    js .watch_error
    mov [rip + inotify_fd], rax

    # Watch the exercises directory
    mov rax, SYS_INOTIFY_ADD_WATCH
    mov rdi, [rip + inotify_fd]
    lea rsi, [rip + exercises_dir]
    mov rdx, IN_WATCH_MASK
    syscall
    test rax, rax
    js .watch_error

.watch_start:
    call find_incomplete
    test rax, rax
    jz .watch_all_done
    mov r14, rax
    jmp .watch_check_exercise

.watch_all_done:
    lea rdi, [rip + clear_screen]
    call print_str
    call print_banner
    lea rdi, [rip + color_green]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + msg_complete]
    call print_str
    call print_reset
    jmp .watch_exit

.watch_loop:
    mov rax, SYS_READ
    mov rdi, [rip + inotify_fd]
    lea rsi, [rip + inotify_buffer]
    mov rdx, INOTIFY_BUF_SIZE
    syscall
    test rax, rax
    jle .watch_sleep

    mov r15, rax
    xor r12, r12

.watch_process_event:
    cmp r12, r15
    jge .watch_event_done

    lea rdi, [rip + inotify_buffer]
    add rdi, r12
    mov eax, [rdi + 12]
    test eax, eax
    jz .watch_next_event

    lea rbx, [rdi + 16]

    mov rdi, rbx
    lea rsi, [rip + ext_s]
    call str_ends_with
    test al, al
    jz .watch_next_event

    mov rdi, rbx
    call find_exercise_by_name
    test rax, rax
    jz .watch_next_event
    mov r14, rax

.watch_check_exercise:
    lea rdi, [rip + clear_screen]
    call print_str
    call print_banner

    mov rdi, r14
    call print_checking_header

    mov rdi, r14
    call check_exercise
    mov byte ptr [r14 + MAX_PATH], al
    mov r13d, eax

    # Use shared result display
    mov edi, r13d
    call print_result

    # Show hint tip for failures
    cmp r13d, STATE_PASSED
    je .watch_handle_passed
    call print_hint_tip
    jmp .watch_show_progress

.watch_handle_passed:
    call find_incomplete
    test rax, rax
    jz .watch_all_complete

    mov r14, rax
    lea rdi, [rip + color_cyan]
    call print_str
    lea rdi, [rip + msg_next]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    mov rdi, r14
    call get_filename_ptr
    mov rdi, rax
    call print_str
    call print_reset
    call print_newline
    jmp .watch_show_progress

.watch_all_complete:
    lea rdi, [rip + color_green]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + msg_complete]
    call print_str
    call print_reset

.watch_show_progress:
    call print_newline
    xor r12, r12
    xor r14, r14
    mov r13, [rip + exercise_count]

.watch_count_passed:
    cmp r12, r13
    jge .watch_print_progress
    mov rdi, r12
    call get_exercise_ptr
    movzx eax, byte ptr [rax + MAX_PATH]
    cmp al, STATE_PASSED
    jne .watch_count_next
    inc r14

.watch_count_next:
    inc r12
    jmp .watch_count_passed

.watch_print_progress:
    mov rdi, r14
    mov rsi, r13
    call print_progress_bar
    call print_newline
    lea rdi, [rip + style_dim]
    lea rsi, [rip + msg_watching]
    call print_colored
    jmp .watch_loop

.watch_next_event:
    lea rdi, [rip + inotify_buffer]
    add rdi, r12
    mov eax, [rdi + 12]
    lea r12, [r12 + rax + 16]
    jmp .watch_process_event

.watch_event_done:
.watch_sleep:
    mov rax, SYS_NANOSLEEP
    lea rdi, [rip + sleeptime]
    xor rsi, rsi
    syscall
    jmp .watch_loop

.watch_no_exercises:
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_no_exercises]
    call print_colored
    jmp .watch_exit

.watch_error:
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_error]
    call print_colored

.watch_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
