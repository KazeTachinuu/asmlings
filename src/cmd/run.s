.section .text

# Run command - execute a specific exercise with stdin passthrough
# rdi = argc, rsi = argv
cmd_run:
    push rbx
    push r12
    push r13
    mov rbx, rdi                    # argc
    mov r13, rsi                    # argv

    cmp rbx, 3
    jl .run_usage

    call load_exercises

    mov rdi, [r13 + 16]             # argv[2]
    call find_exercise
    test rax, rax
    jz .run_not_found

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
    call print_reset
    call print_newline

    # Load expected file (sets up gcc mode flag, etc.)
    mov rdi, r12
    call load_expected_file

    # Compile
    mov rdi, r12
    call compile_exercise
    test al, al
    jz .run_compile_failed

    # Run with stdin passthrough
    xor edi, edi                    # no output capture
    mov rsi, -1                     # stdin passthrough
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
