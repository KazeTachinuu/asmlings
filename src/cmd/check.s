.section .text

# Check command - check status of a specific exercise
# rdi = argc, rsi = argv
cmd_check:
    push rbx
    push r12
    push r13
    mov rbx, rdi                    # argc
    mov r13, rsi                    # argv

    cmp rbx, 3
    jl .chk_usage

    call load_exercises

    mov rdi, [r13 + 16]             # argv[2]
    call find_exercise
    test rax, rax
    jz .chk_not_found

    mov r12, rax

    # Print checking header
    mov rdi, r12
    call print_checking_header

    # Check exercise
    mov rdi, r12
    call check_exercise

    # Display result using shared helper
    mov edi, eax
    call print_result
    jmp .chk_exit

.chk_not_found:
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_not_found]
    call print_colored
    jmp .chk_exit

.chk_usage:
    lea rdi, [rip + msg_check_usage]
    call print_str

.chk_exit:
    pop r13
    pop r12
    pop rbx
    ret
