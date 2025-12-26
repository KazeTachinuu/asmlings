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
    lea rdi, [rip + color_reset]
    call print_str
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

    # Watch the exercises directory (catches atomic saves from editors)
    mov rax, SYS_INOTIFY_ADD_WATCH
    mov rdi, [rip + inotify_fd]
    lea rsi, [rip + exercises_dir]
    mov rdx, IN_WATCH_MASK
    syscall
    test rax, rax
    js .watch_error

.watch_start:
    # Find first incomplete exercise
    call find_incomplete
    test rax, rax
    jz .watch_all_done

    mov r14, rax

    # Check and display current exercise (same as event handler)
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
    lea rdi, [rip + color_reset]
    call print_str
    jmp .watch_exit

.watch_loop:
    # Wait for file changes
    mov rax, SYS_READ
    mov rdi, [rip + inotify_fd]
    lea rsi, [rip + inotify_buffer]
    mov rdx, INOTIFY_BUF_SIZE
    syscall
    test rax, rax
    jle .watch_sleep

    mov r15, rax                    # bytes read
    xor r12, r12                    # offset

.watch_process_event:
    cmp r12, r15
    jge .watch_event_done

    # Get event info
    lea rdi, [rip + inotify_buffer]
    add rdi, r12
    # inotify_event: wd(4), mask(4), cookie(4), len(4), name[]
    mov eax, [rdi + 12]             # len (filename length)
    test eax, eax
    jz .watch_next_event            # no filename, skip

    # Get filename pointer (at offset 16)
    lea rbx, [rdi + 16]

    # Check if it ends with .s
    mov rdi, rbx
    lea rsi, [rip + ext_s]
    call str_ends_with
    test al, al
    jz .watch_next_event            # not a .s file, skip

    # Find exercise by filename
    mov rdi, rbx
    call find_exercise_by_name
    test rax, rax
    jz .watch_next_event            # exercise not found
    mov r14, rax

.watch_check_exercise:
    # Clear screen and show banner
    lea rdi, [rip + clear_screen]
    call print_str
    call print_banner

    # Check the exercise
    lea rdi, [rip + msg_checking]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    mov rdi, r14
    call get_filename_ptr
    mov rdi, rax
    call print_str
    lea rdi, [rip + color_reset]
    call print_str
    call print_newline

    mov rdi, r14
    call check_exercise
    mov byte ptr [r14 + MAX_PATH], al
    mov r13, rax

    cmp r13, STATE_PASSED
    je .watch_ex_passed

    cmp r13, STATE_NOT_DONE
    je .watch_ex_not_done

    cmp r13, STATE_WRONG_EXIT
    je .watch_ex_wrong_exit

    cmp r13, STATE_WRONG_OUTPUT
    je .watch_ex_wrong_output

    cmp r13, STATE_WRONG_PREDICT
    je .watch_ex_wrong_predict

    # Compilation failed
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_failed]
    call print_colored
    lea rdi, [rip + style_dim]
    lea rsi, [rip + msg_hint_tip]
    call print_colored
    jmp .watch_show_progress

.watch_ex_wrong_output:
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_wrong_output]
    call print_colored
    # Show expected
    lea rdi, [rip + style_dim]
    call print_str
    lea rdi, [rip + msg_expected_out]
    call print_str
    lea rdi, [rip + expected_output]
    call print_str
    lea rdi, [rip + msg_quote_end]
    call print_str
    # Show actual
    lea rdi, [rip + msg_actual_out]
    call print_str
    lea rdi, [rip + actual_output]
    call print_str
    lea rdi, [rip + msg_quote_end]
    call print_str
    lea rdi, [rip + color_reset]
    call print_str
    lea rdi, [rip + style_dim]
    lea rsi, [rip + msg_hint_tip]
    call print_colored
    jmp .watch_show_progress

.watch_ex_wrong_exit:
    # Show actual vs expected
    lea rdi, [rip + color_red]
    call print_str
    lea rdi, [rip + msg_wrong_exit]
    call print_str
    mov rdi, [rip + last_exit_actual]
    call print_number
    lea rdi, [rip + msg_expected]
    call print_str
    mov rdi, [rip + last_exit_expected]
    call print_number
    lea rdi, [rip + color_reset]
    call print_str
    call print_newline
    lea rdi, [rip + style_dim]
    lea rsi, [rip + msg_hint_tip]
    call print_colored
    jmp .watch_show_progress

.watch_ex_wrong_predict:
    # Predict exercise - don't reveal the answer
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_wrong_predict]
    call print_colored
    lea rdi, [rip + style_dim]
    lea rsi, [rip + msg_hint_tip]
    call print_colored
    jmp .watch_show_progress

.watch_ex_not_done:
    lea rdi, [rip + color_yellow]
    lea rsi, [rip + msg_not_done]
    call print_colored
    lea rdi, [rip + style_dim]
    call print_str
    lea rdi, [rip + msg_remove_marker]
    call print_str
    lea rdi, [rip + msg_hint_tip]
    call print_str
    lea rdi, [rip + color_reset]
    call print_str
    jmp .watch_show_progress

.watch_ex_passed:
    lea rdi, [rip + color_green]
    lea rsi, [rip + msg_passed]
    call print_colored

    # Find next incomplete
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
    lea rdi, [rip + color_reset]
    call print_str
    call print_newline
    jmp .watch_show_progress

.watch_all_complete:
    lea rdi, [rip + color_green]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + msg_complete]
    call print_str
    lea rdi, [rip + color_reset]
    call print_str

.watch_show_progress:
    call print_newline
    # Count passed
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
    # Move to next event: sizeof(inotify_event) = 16 + len
    lea rdi, [rip + inotify_buffer]
    add rdi, r12
    mov eax, [rdi + 12]             # len (dword)
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

# Hint command
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
    call find_exercise_by_num
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
    lea rdi, [rip + color_reset]
    call print_str
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

# Run command - execute a specific exercise with stdin passthrough
# rdi = argc, rsi = argv
cmd_run:
    push rbx
    push r12
    push r13
    mov rbx, rdi                    # argc
    mov r13, rsi                    # argv

    # Check for exercise argument
    cmp rbx, 3
    jl .run_usage

    call load_exercises

    # Find exercise by number
    mov rdi, [r13 + 16]             # argv[2]
    call find_exercise_by_num
    test rax, rax
    jnz .run_found

    # Try by filename
    mov rdi, [r13 + 16]
    call find_exercise_by_name
    test rax, rax
    jz .run_not_found

.run_found:
    mov r12, rax

    # Print "Running <exercise>"
    lea rdi, [rip + msg_running]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    mov rdi, r12
    call get_filename_ptr
    mov rdi, rax
    call print_str
    lea rdi, [rip + color_reset]
    call print_str
    call print_newline

    # Compile
    mov rdi, r12
    call compile_exercise
    test al, al
    jz .run_compile_failed

    # Run with stdin passthrough (rsi=-1 means keep stdin)
    xor edi, edi                    # no output capture
    mov rsi, -1                     # -1 = stdin passthrough
    call run_exercise
    mov r12, rax                    # save exit code

    # Print exit code
    lea rdi, [rip + msg_exit_code]
    call print_str
    mov rdi, r12
    call print_number
    call print_newline
    jmp .run_exit

.run_compile_failed:
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_failed]
    call print_colored
    jmp .run_exit

.run_not_found:
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_not_found]
    call print_colored
    jmp .run_exit

.run_usage:
    lea rdi, [rip + msg_run_usage]
    call print_str

.run_exit:
    pop r13
    pop r12
    pop rbx
    ret

# Help command
cmd_help:
    push rbx

    # Title
    lea rdi, [rip + color_cyan]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + help_title]
    call print_str
    lea rdi, [rip + color_reset]
    call print_str
    lea rdi, [rip + help_subtitle]
    call print_str

    # Usage section
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + help_usage_hdr]
    call print_str
    lea rdi, [rip + color_reset]
    call print_str
    lea rdi, [rip + help_usage]
    call print_str

    # Commands section
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + help_cmds_hdr]
    call print_str
    lea rdi, [rip + color_reset]
    call print_str
    lea rdi, [rip + help_cmds]
    call print_str

    # Getting started section
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + help_start_hdr]
    call print_str
    lea rdi, [rip + color_reset]
    call print_str
    lea rdi, [rip + help_start]
    call print_str

    pop rbx
    ret

help_title:     .asciz "asmlings"
help_subtitle:  .asciz " - Learn x86-64 assembly by fixing exercises\n\n"
help_usage_hdr: .asciz "USAGE:\n"
help_usage:     .asciz "    ./asmlings [COMMAND]\n\n"
help_cmds_hdr:  .asciz "COMMANDS:\n"
help_cmds:
    .ascii "    watch      Watch for changes and check exercises (default)\n"
    .ascii "    run N      Run exercise N with stdin passthrough (e.g. run 35)\n"
    .ascii "    list       Show all exercises with status\n"
    .ascii "    hint [N]   Show hint for current or exercise N (e.g. hint 05)\n"
    .ascii "    help       Show this help message\n\n"
    .byte 0
help_start_hdr: .asciz "GETTING STARTED:\n"
help_start:
    .ascii "    1. Run ./asmlings watch\n"
    .ascii "    2. Open exercises/01_intro.s in your editor\n"
    .ascii "    3. Read the instructions and fix the code\n"
    .ascii "    4. Remove '# I AM NOT DONE' when ready\n"
    .ascii "    5. Save - asmlings will check your solution!\n\n"
    .byte 0

